import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/sdk/xboard_sdk.dart' as sdk;
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart' as xb_sdk;

/// XBoard 订单仓储实现
class XBoardOrderRepository implements OrderRepository {
  final _logger = FileLogger('XBoardOrderRepository');

  @override
  Future<Result<List<DomainOrder>>> getOrders() async {
    try {
      _logger.info('获取订单列表...');
      
      final orders = await sdk.XBoardSDK.getOrders();
      
      final domainOrders = orders.map(_mapToDomain).toList();
      
      _logger.info('订单列表获取成功，共 ${domainOrders.length} 个');
      return Result.success(domainOrders);
      
    } on XBoardException catch (e) {
      _logger.info('获取订单列表失败: ${e.message}');
      return Result.failure(e);
    } catch (e) {
      _logger.info('获取订单列表异常: $e');
      return Result.failure(
        XBoardException(
          code: 'GET_ORDERS_ERROR',
          message: '获取订单列表失败: $e',
        ),
      );
    }
  }

  @override
  Future<Result<DomainOrder>> getOrderByTradeNo(String tradeNo) async {
    try {
      _logger.info('获取订单详情: $tradeNo');
      
      final order = await sdk.XBoardSDK.getOrderByTradeNo(tradeNo);
      
      if (order == null) {
        return Result.failure(
          XBoardException(
            code: 'ORDER_NOT_FOUND',
            message: '订单不存在',
          ),
        );
      }
      
      final domainOrder = _mapToDomain(order);
      
      _logger.info('订单详情获取成功');
      return Result.success(domainOrder);
      
    } on XBoardException catch (e) {
      _logger.info('获取订单详情失败: ${e.message}');
      return Result.failure(e);
    } catch (e) {
      _logger.info('获取订单详情异常: $e');
      return Result.failure(
        XBoardException(
          code: 'GET_ORDER_ERROR',
          message: '获取订单详情失败: $e',
        ),
      );
    }
  }

  @override
  Future<Result<String>> createOrder({
    required int planId,
    required String period,
    String? couponCode,
  }) async {
    try {
      _logger.info('创建订单: planId=$planId, period=$period');
      
      final tradeNo = await sdk.XBoardSDK.createOrder(
        planId: planId,
        period: period,
        couponCode: couponCode,
      );
      
      _logger.info('订单创建成功: $tradeNo');
      return Result.success(tradeNo ?? '');
      
    } on XBoardException catch (e) {
      _logger.info('创建订单失败: ${e.message}');
      return Result.failure(e);
    } catch (e) {
      _logger.info('创建订单异常: $e');
      return Result.failure(
        XBoardException(
          code: 'CREATE_ORDER_ERROR',
          message: '创建订单失败: $e',
        ),
      );
    }
  }

  @override
  Future<Result<void>> cancelOrder(String tradeNo) async {
    try {
      _logger.info('取消订单: $tradeNo');
      
      await sdk.XBoardSDK.cancelOrder(tradeNo);
      
      _logger.info('订单取消成功');
      return Result.success(null);
      
    } on XBoardException catch (e) {
      _logger.info('取消订单失败: ${e.message}');
      return Result.failure(e);
    } catch (e) {
      _logger.info('取消订单异常: $e');
      return Result.failure(
        XBoardException(
          code: 'CANCEL_ORDER_ERROR',
          message: '取消订单失败: $e',
        ),
      );
    }
  }

  // ========== 私有方法：数据转换 ==========

  DomainOrder _mapToDomain(xb_sdk.Order sdkOrder) {
    return DomainOrder(
      tradeNo: sdkOrder.tradeNo ?? '',
      planId: sdkOrder.planId ?? 0,
      period: sdkOrder.period ?? '',
      totalAmount: sdkOrder.totalAmount ?? 0.0,
      status: OrderStatus.fromCode(sdkOrder.status ?? 0),
      planName: sdkOrder.orderPlan?.name,
      createdAt: sdkOrder.createdAt ?? DateTime.now(),
      metadata: {
        'source': 'xboard',
      },
    );
  }
}
