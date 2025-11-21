import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/sdk/xboard_sdk.dart' as sdk;
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart' as xb_sdk;

/// XBoard 套餐仓储实现
class XBoardPlanRepository implements PlanRepository {
  final _logger = FileLogger('XBoardPlanRepository');

  @override
  Future<Result<List<DomainPlan>>> getPlans() async {
    try {
      _logger.info('获取套餐列表...');
      
      final plans = await sdk.XBoardSDK.getPlans();
      
      // 转换为领域模型
      final domainPlans = plans.map(_mapToDomain).toList();
      
      _logger.info('套餐列表获取成功，共 ${domainPlans.length} 个');
      return Result.success(domainPlans);
      
    } on XBoardException catch (e) {
      _logger.info('获取套餐列表失败: ${e.message}');
      return Result.failure(e);
    } catch (e) {
      _logger.info('获取套餐列表异常: $e');
      return Result.failure(
        XBoardException(
          code: 'GET_PLANS_ERROR',
          message: '获取套餐列表失败: $e',
        ),
      );
    }
  }

  @override
  Future<Result<DomainPlan>> getPlanById(int id) async {
    try {
      _logger.info('获取套餐详情: $id');
      
      final plans = await sdk.XBoardSDK.getPlans();
      final plan = plans.firstWhere(
        (p) => p.id == id,
        orElse: () => throw XBoardException(
          code: 'PLAN_NOT_FOUND',
          message: '套餐不存在',
        ),
      );
      
      final domainPlan = _mapToDomain(plan);
      
      _logger.info('套餐详情获取成功: ${domainPlan.name}');
      return Result.success(domainPlan);
      
    } on XBoardException catch (e) {
      _logger.info('获取套餐详情失败: ${e.message}');
      return Result.failure(e);
    } catch (e) {
      _logger.info('获取套餐详情异常: $e');
      return Result.failure(
        XBoardException(
          code: 'GET_PLAN_ERROR',
          message: '获取套餐详情失败: $e',
        ),
      );
    }
  }

  // ========== 私有方法：数据转换 ==========

  DomainPlan _mapToDomain(xb_sdk.Plan sdkPlan) {
    return DomainPlan(
      id: sdkPlan.id,
      name: sdkPlan.name,
      groupId: sdkPlan.groupId,
      transferQuota: sdkPlan.transferEnable.toInt(),
      description: sdkPlan.content,
      tags: sdkPlan.tags ?? [],
      speedLimit: sdkPlan.speedLimit,
      deviceLimit: sdkPlan.deviceLimit,
      isVisible: sdkPlan.show,
      renewable: sdkPlan.renew,
      sort: sdkPlan.sort,
      
      // 价格信息（SDK 已经转换为元）
      onetimePrice: sdkPlan.onetimePrice,
      monthlyPrice: sdkPlan.monthPrice,
      quarterlyPrice: sdkPlan.quarterPrice,
      halfYearlyPrice: sdkPlan.halfYearPrice,
      yearlyPrice: sdkPlan.yearPrice,
      twoYearPrice: sdkPlan.twoYearPrice,
      threeYearPrice: sdkPlan.threeYearPrice,
      resetPrice: sdkPlan.resetPrice,
      
      // 时间信息
      createdAt: sdkPlan.createdAt != null 
        ? DateTime.fromMillisecondsSinceEpoch(sdkPlan.createdAt! * 1000)
        : null,
      updatedAt: sdkPlan.updatedAt != null
        ? DateTime.fromMillisecondsSinceEpoch(sdkPlan.updatedAt! * 1000)
        : null,
      
      metadata: {
        'source': 'xboard',
        'capacity_limit': sdkPlan.capacityLimit,
        'reset_traffic_method': sdkPlan.resetTrafficMethod,
      },
    );
  }
}
