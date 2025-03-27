import 'dart:async';
import 'dart:io' show Platform;

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:letrarium/services/level_service.dart';

class PurchaseService {
  // Singleton pattern
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  // Instância do plugin de compras
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  // Serviço de níveis
  final LevelService _levelService = LevelService();

  // Stream subscription para os eventos de compra
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Lista de produtos disponíveis para compra
  List<ProductDetails> _products = [];

  // Status da conexão com a loja
  bool _isAvailable = false;

  // IDs dos produtos
  final Set<String> _productIds = {
    'unlock_all_levels',
  };

  // Getters
  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;

  // Método para inicializar o serviço
  Future<void> initialize() async {
    try {
      // Verifica se a loja está disponível
      _isAvailable = await _inAppPurchase.isAvailable();

      if (!_isAvailable) {
        print('A loja não está disponível');
        return;
      }

      // Configura o listener para eventos de compra
      _subscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdate,
        onDone: _updateStreamOnDone,
        onError: _updateStreamOnError,
      );

      // Carrega os produtos
      await _loadProducts();
    } catch (e) {
      print('Erro ao inicializar o serviço de compras: $e');
      _isAvailable = false;
    }
  }

  Future<void> _loadProducts() async {
    try {
      print("Iniciando carregamento de produtos...");
      print("IDs de produtos a serem consultados: $_productIds");

      final ProductDetailsResponse response =
      await _inAppPurchase.queryProductDetails(_productIds);

      if (response.notFoundIDs.isNotEmpty) {
        print('Produtos não encontrados: ${response.notFoundIDs}');
        print('Erro de resposta completo: $response');
      }

      _products = response.productDetails;
      print('Produtos carregados: ${_products.length}');
      if (_products.isNotEmpty) {
        for (var product in _products) {
          print('Produto encontrado: ${product.id}, ${product.title}, ${product.price}');
        }
      }
    } catch (e) {
      print('Erro detalhado ao carregar produtos: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  // Inicia uma compra
  Future<bool> buyProduct(ProductDetails product) async {
    if (!_isAvailable) {
      print('A loja não está disponível');
      return false;
    }

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: null,
      );

      // Todos os nossos produtos são não consumíveis
      return await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print('Erro ao iniciar compra: $e');
      return false;
    }
  }

  // Restaura compras anteriores
  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      print('A loja não está disponível');
      return;
    }

    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      print('Erro ao restaurar compras: $e');
    }
  }

  // Manipula os eventos de compra
  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Compra pendente - mostrar indicador de carregamento
        print('Compra pendente: ${purchaseDetails.productID}');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Erro na compra
        print('Erro na compra: ${purchaseDetails.error}');
        // Mostrar mensagem de erro para o usuário
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Compra concluída ou restaurada
        print('Compra concluída: ${purchaseDetails.productID}');

        // Verificar a compra no servidor (recomendado para segurança)
        final bool valid = await _verifyPurchase(purchaseDetails);

        if (valid) {
          // Entregar o produto ao usuário
          await _deliverProduct(purchaseDetails);
        } else {
          // Compra inválida - informar o usuário
          print('Compra inválida!');
        }

        // Finalizar a transação
        if (Platform.isIOS) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        // Compra cancelada pelo usuário
        print('Compra cancelada: ${purchaseDetails.productID}');
      }
    });
  }

  // Verifica a validade da compra (deve implementar verificação no servidor)
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // Implementação real deveria verificar a assinatura no servidor
    // Para Android: Verificar token usando Google Play Developer API
    // Para iOS: Verificar recibo usando App Store Receipt Validation API

    // Esta é uma implementação básica para exemplo
    return true;
  }

  // Entrega o produto comprado ao usuário
  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    // Implementar a lógica para entregar o produto
    if (purchaseDetails.productID == 'unlock_all_levels') {
      await _unlockAllLevels();
    }
  }

  // Desbloqueia todos os níveis
  Future<void> _unlockAllLevels() async {
    await _levelService.unlockAllLevels();
    print('Todos os níveis desbloqueados');
  }

  // Manipula o encerramento do stream
  void _updateStreamOnDone() {
    _subscription?.cancel();
  }

  // Manipula erros no stream
  void _updateStreamOnError(dynamic error) {
    print('Erro no stream de compras: $error');
  }

  // Libera recursos ao encerrar o app
  void dispose() {
    _subscription?.cancel();
  }
}
