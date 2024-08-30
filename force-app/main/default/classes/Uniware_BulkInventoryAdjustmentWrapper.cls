public without sharing class Uniware_BulkInventoryAdjustmentWrapper {
    
    public cls_inventoryAdjustments[] inventoryAdjustments;
	public class cls_inventoryAdjustments {
		public String itemSKU;	//string
		public Integer quantity;	//0
		public String shelfCode;	//string
		public String inventoryType;	//GOOD_INVENTORY
		public String transferToShelfCode;	//string
		public Integer sla;	//0
		public String adjustmentType;	//ADD
		public String remarks;	//string
		public String facilityCode;	//string
	}
    
	public static Uniware_BulkInventoryAdjustmentWrapper parse(String json){
		return (Uniware_BulkInventoryAdjustmentWrapper) System.JSON.deserialize(json, Uniware_BulkInventoryAdjustmentWrapper.class);
	}

}