public without sharing class Uniware_SingleInventoryAdjustmentWrapper {
    
    public cls_inventoryAdjustment inventoryAdjustment;
	public class cls_inventoryAdjustment {
		public String itemSKU;	//string
		public Integer quantity;	//0
		public String shelfCode;	//string
		public String inventoryType;	//GOOD_INVENTORY
		public String transferToShelfCode;	//string
		public Integer sla;	//0
		public String adjustmentType;	//ADD
		public String remarks;	//string
	}
    
	public static Uniware_SingleInventoryAdjustmentWrapper parse(String json){
		return (Uniware_SingleInventoryAdjustmentWrapper) System.JSON.deserialize(json, Uniware_SingleInventoryAdjustmentWrapper.class);
	}

}