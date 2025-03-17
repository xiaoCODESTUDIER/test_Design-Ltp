// import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart';

// import 'package:flutter/material.dart';
// class ScrollableListView extends StatelessWidget {
//   final List<String> items;
//   final Function(int)? onItemTap;
//   ScrollableListView({required this.items, this.onItemTap});
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: items.length,
//       itemBuilder: (context, index) {
//         return ListTile(
//           title: Text(items[index]),
//           onTap: () {
//             if (onItemTap != null) {
//               onItemTap!(index);
//             }
//           }
//         );
//       }
//     );
//   }
// }

// public class GetDepartmentSalerID : Function
// {
//   public override object Execute()
//   {
//     var salerId = GetArgumentValue<int?>("SalerID");
//     if(salerId == null)
//     {
//       throw new ArgumentNullException("SalerID");
//     }
//     var result = new List<SignerInfo>();
//     OaContext oaDB = (OaContext)GetDbContext("OaContext");
//     AuthenticationContext auDB = (AuthenticationContext)GetDbContext("AuthenticationContext");
//     var saler = oaDB.UserExtInfos.Where(r=>r.ERPCode == salerId.ToString()).FirstOrDefault();
//     if(saler == null)
//     {
//       throw new Exception("业务员未维护协同ERP对码");
//     }
//     Authentication.Entities.TCAUsers user = auDB.TCAUsers
//         .Include(r=>r.TCAUserOrgsUser)
//         .ThenInclude(r=>r.Org)
//         .ThenInclude(r=>r.TCAOrgLeaders)
//         .Where(c=>c.UserId == saler.UserId).FirstOrDefault();
//     if(user != null && user.TCAUserOrgsUser.Count > 0)
//     {
//       var salerOrg = user.TCAUserOrgsUser.Where(r=>r.IsMaster == true && r.Status == (int)StatusEnum.Enable).FirstOrDefault()?.Org;
//       if(salerOrg == null)
//       {
//         throw new Exception("人员未维护部门主岗");
//       }
//       if(salerOrg != null&& salerOrg.TCAOrgLeaders != null && salerOrg.TCAOrgLeaders.Count > 0)
//       {
//         result.AddRange(
//           salerOrg.TCAOrgLeaders.Where(r=>r.Status == (int)StatusEnum.Enabled && r.LeaderUser != null)
//           .Select(r=>new SignerInfo()
//           {
//             UserId = r.LeaderUser.UserId,
//             RealName = r.LeaderUser.RealName
//           }).ToList()
//         );
//       }
//     }
//     return result;
//   }
// }

// function(FlowContext: unknown, HttpContext: unknown, FlowStep: unknown, Apply: unknown): unknown[] {
//   let ApplyID: unknown = [];
//   let ApplyIDs: number[] = [];
//   let Condition: unknown = [];
//   let ApplyIDArray: unknown[] = [];
//   let DeveloperID: string[] = [];
//   let UserID: number[] = [];
//   let SignerInfoList: unknown = [];
//   ApplyID = GetApplyByTCFFlowApplies(Apply, "ApplyID");
//   Condition = EqualCondition("ApplyID", ApplyID, false);
//   ApplyIDArray = GetDbEntities("OaContext", "TO2Off");
//   ApplyIDArray = Where(ApplyIDArray, Condition);
//   DeveloperID = ToList(Select(false, ApplyIDArray, "SalerID"));
//   return GetDepatmentLeadersByErpSalerID(DeveloperID);
// }

// public class GetSalerName : Function
// {
//   public override object Execute()
//   {
//     var salerId = GetArgumentValue<int?>("SalerID");
//     if (salerId == null)
//     {
//       throw new ArgumentNullException("SalerID");
//     }
//     OaContext oaDB = (OaContext)GetDbContext("OaContext");
//     var saler = oaDB.UserExtInfos
//                    .Where(r => r.ERPCode == salerId.ToString())
//                    .FirstOrDefault();
//     if (saler == null)
//     {
//       throw new Exception("业务员未维护协同ERP对码");
//     }
//     result.AddRange(
//                     oaDB.UserExtInfos
//                    .Where(r => r.ERPCode == salerId.ToString())
//                    .Select(r => new SignerInfo(){
//                     UserId = r.UserId,
//                     RealName = r.RealName
//                    }).ToList());
//     )
//     // 返回销售员的名字
//     return result;
//   }
// }

// {
//   columnKey: 'CertID_Editor',
//   field: 'certID',
//   title: '认定材料',
//   hideTitle: false,
//   visible: true,
//   mobileVisible: true,
//   required: false,
//   readonly: false,
//   type: 'checkbox',
//   stringLength: 100,
//   rules: [],
//   componentName: 'COptionGroupEditor',
//   componentConfig: <OptionGroupConfig>{
//     optionLabel: 'label',
//     optionValue: 'value',
//     deepWatch: true,
//     options(){
//       const data = this.dataItem as Entity.Core.Oa.Entities.TO2Two;
//       const temp = data.typeID;
//       if (temp == 1){
//         return GetSelected.call(this,[1,2,3,4]);
//       } if (temp == 2) {
//         return GetSelected.call(this, [5,3,6,4]);
//       }
//     }
//     onInput(val:{optionLabel: string, optionValue: number}){
//       const data = this.dataItem as Entity.Core.Oa.Entities.TO2Two;
//       data.certName = ((this.$data.options as TRecord[])
//                        .filter(item => item.value == val)
//                        .map((item) => item.label))
//                        .toString();
//     },
//   },
// },
// const GetSelected: (this: Editor, ids: number[]) => TRecord[] | null = function(
//   ids = []
// ) {
//   const temp = [
//     {lavel: 'a', value: 1},
//     ...
//     ...
//   ];
//   return XEUtils.filter(temp, i => XEUtils.find(ids, (d) => d === i.value) !== undefined);
// }

// const SelectValue = XEUtils.toJSONString(this.$data.options);
// data.certID = XEUtils.find