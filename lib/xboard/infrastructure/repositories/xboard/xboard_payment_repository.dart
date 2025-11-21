import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/sdk/xboard_sdk.dart' as sdk;
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart' as xb_sdk;

/// XBoard 支付仓储实现
class XBoardPaymentRepository implements PaymentRepository {
  final _logger = FileLogger('XBoardPaymentRepository');

  @override
  Future<Result<List<DomainPaymentMethod>>> getPaymentMethods() async {
    try {
      _logger.info('获取支付方式列表...');
      
      final methods = await sdk.XBoardSDK.getPaymentMethods();
      
      final domainMethods = methods.map(_mapToDomain).toList();
      
      _logger.info('支付方式列表获取成功，共 ${domainMethods.length} 个');
      return Result.success(domainMethods);
      
    } on XBoardException catch (e) {
      _logger.info('获取支付方式列表失败: ${e.message}');
      return Result.failure(e);
    } catch (e) {
      _logger.info('获取支付方式列表异常: $e');
      return Result.failure(
        XBoardException(
          code: 'GET_PAYMENT_METHODS_ERROR',
          message: '获取支付方式列表失败: $e',
        ),
      );
    }
  }

  @override
  Future<Result<PaymentResult>> submitPayment({
    required String tradeNo,
    required int methodId,
  }) async {
    try {
      _logger.info('提交支付: tradeNo=$tradeNo, methodId=$methodId');
      
      final response = await sdk.XBoardSDK.submitPayment(
        tradeNo: tradeNo,
        method: methodId,
      );
      
      // response 可能为空
      if (response == null) {
        return Result.failure(
          XBoardException(
            code: 'PAYMENT_FAILED',
            message: '支付提交失败',
          ),
        );
      }
      
      final paymentResult = PaymentResult(
        type: response['type'] as int? ?? 0,
        data: response['data']?.toString(),
      );
      
      _logger.info('支付类型: ${paymentResult.type}');
      return Result.success(paymentResult);
      
    } on XBoardException catch (e) {
      _logger.info('支付提交失败: ${e.message}');
      return Result.failure(e);
    } catch (e) {
      _logger.info('支付提交异常: $e');
      return Result.failure(
        XBoardException(
          code: 'SUBMIT_PAYMENT_ERROR',
          message: '支付提交失败: $e',
        ),
      );
    }
  }

  @override
  Future<Result<int>> checkPaymentStatus(String tradeNo) async {
    try {
      _logger.info('查询支付状态: $tradeNo');
      
      final status = await sdk.XBoardSDK.checkPaymentStatus(tradeNo) ?? 0;
      
      _logger.info('支付状态: $status');
      return Result.success(status);
      
    } on XBoardException catch (e) {
      _logger.info('查询支付状态失败: ${e.message}');
      return Result.failure(e);
    } catch (e) {
      _logger.info('查询支付状态异常: $e');
      return Result.failure(
        XBoardException(
          code: 'CHECK_PAYMENT_STATUS_ERROR',
          message: '查询支付状态失败: $e',
        ),
      );
    }
  }

  // ========== 私有方法：数据转换 ==========

  DomainPaymentMethod _mapToDomain(xb_sdk.PaymentMethodInfo sdkMethod) {
    // SDK 的 id 是 String 类型，需要转换为 int
    final methodId = int.tryParse(sdkMethod.id) ?? 0;
    
    return DomainPaymentMethod(
      id: methodId,
      name: sdkMethod.name,
      iconUrl: sdkMethod.icon,
      feePercentage: sdkMethod.feePercent,
      isAvailable: sdkMethod.isAvailable ?? true,
      metadata: {
        'source': 'xboard',
        'id_string': sdkMethod.id,  // 保留原始字符串ID
        'config': sdkMethod.config,
        'min_amount': sdkMethod.minAmount,
        'max_amount': sdkMethod.maxAmount,
      },
    );
  }
}
