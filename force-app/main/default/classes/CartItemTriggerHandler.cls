public class CartItemTriggerHandler {    
    public void handleBeforeInsert(List<CartItem> newList){

        Id userId = UserInfo.getUserId();
        WebCart cart = [Select Id, Color_Info__c From WebCart Where Id =: newList[0].CartId];
        String ColorCode = [Select Color_Hex__c From User Where Id =: userId].Color_Hex__c;
		List<Product_Paint_Color__c> hasColors = [Select Id from Product_Paint_Color__c Where Product__c =: newList[0].Product2Id];
        if(hasColors.size() <= 0)
            return;
        String ColorName = [Select Name From Paint_Color__c  Where Hex_Code__c =: ColorCode].Name;
		String colorInfo = cart.Color_Info__c;
        
        Set<Id> productIds = new Set<Id>();
        for(CartItem a : newList){
            productIds.add(a.Product2Id);
        }
        Map<Id, Product2> mapProds = new Map<Id, Product2>([Select Id, StockKeepingUnit, AMS_Size__c From Product2 Where Id in: productIds]);
        
        System.debug(colorCode);
        for(CartItem a : newList){
            System.debug(a.Name);
            if(ColorCode != null && mapProds.get(a.Product2Id).AMS_Size__c.contains('L')){
                String productSKU = mapProds.get(a.Product2Id).StockKeepingUnit;
                ColorClass newColorInfo = new ColorClass(productSKU,ColorName,ColorCode,a.Quantity);
                UpdateUser(userId);
                UpdateCart(cart.Id,newColorInfo.toString());
            }else{
                a.addError('No color picked');
            }        
        } 
        
    }
    
    public void handleBeforeUpdate(List<CartItem> newList, Map<Id, CartItem> oldMap){

        Id userId = UserInfo.getUserId();
        WebCart cart = [Select Id, Color_Info__c From WebCart Where Id =: newList[0].CartId];
        String ColorCode = [Select Color_Hex__c From User Where Id =: userId].Color_Hex__c;
        List<Product_Paint_Color__c> hasColors = [Select Id from Product_Paint_Color__c Where Product__c =: newList[0].Product2Id];
        if(hasColors.size() <= 0 || ColorCode == null)
            return;
        System.debug('color code: ' + ColorCode);
        String ColorName = [Select Name From Paint_Color__c  Where Hex_Code__c =: ColorCode].Name;
		String colorInfo = cart.Color_Info__c;
                
        Set<Id> productIds = new Set<Id>();
        for(CartItem a : newList){
            productIds.add(a.Product2Id);
        }
        Map<Id, Product2> mapProds = new Map<Id, Product2>([Select Id, StockKeepingUnit, AMS_Size__c From Product2 Where Id in: productIds]);
        
        System.debug(colorCode);
        for(CartItem a : newList){
            if(ColorCode != null && mapProds.get(a.Product2Id).AMS_Size__c.contains('L')){
                String productSKU = mapProds.get(a.Product2Id).StockKeepingUnit;
                Decimal quantity = a.Quantity - oldMap.get(a.Id).Quantity;
                ColorClass newColorInfo = new ColorClass(productSKU,ColorName,ColorCode,quantity);
                UpdateUser(userId);
                UpdateCart(cart.Id,newColorInfo.toString());
            }else{
                a.addError('No color picked');
            }        
        } 
        
    }
    
    public void handleBeforeDelete(List<CartItem> oldList){
        WebCart cart = [Select Id, Color_Info__c From WebCart Where Id =: oldList[0].CartId];
        if(cart.Color_Info__c == null)
            return;
        
        List<ColorClass> colors = (List<ColorClass>)JSON.deserialize('['+cart.Color_Info__c+']', List<ColorClass>.class);
        Map<String, ColorClass> mapColorsByHex = new Map<String, ColorClass>();
        for(ColorClass color : colors){
            mapColorsByHex.put(color.ColorCode, color);
        }
        
        Set<Id> productIds = new Set<Id>();
        for(CartItem a : oldList){
            productIds.add(a.Product2Id);
        }
        Map<Id, Product2> mapProds = new Map<Id, Product2>([Select Id, StockKeepingUnit From Product2 Where Id in: productIds]);
        
        for(CartItem a : oldList){
            for(ColorClass color : mapColorsByHex.values()){
                System.debug('color: ' + color);
                System.debug('prodcut: ' + mapProds.get(a.Product2Id).StockKeepingUnit);
                if(color.ProductSKU == mapProds.get(a.Product2Id).StockKeepingUnit){
                    System.debug(mapColorsByHex.values());
                    mapColorsByHex.remove(color.ColorCode);
                    System.debug(mapColorsByHex.values());
                }
            }
        }
        
        String colorInfo = JSON.serializePretty(mapColorsByHex.values());
        System.debug(colorInfo);
        colorInfo = colorInfo.remove('[');
        colorInfo = colorInfo.remove(']');
        ClearCart(cart.Id, colorInfo);
    }
    
    @future
    public static void UpdateUser(String userId){
        User thisUser = [Select Id, Color_Hex__c From User Where Id =: userId];
        thisUser.Color_Hex__c = '';
        update thisUser;
    }
    
    @future
    public static void UpdateCart(String cartId, String cartInfo){
        WebCart cartUpdate = [Select Id, Color_Info__c From WebCart Where Id =: cartId];
        if(cartUpdate.Color_Info__c != null)
        	cartUpdate.Color_Info__c = cartUpdate.Color_Info__c + ',\r\n' + cartInfo;
        else
            cartUpdate.Color_Info__c = cartInfo;
        update cartUpdate;
    }
    
    @future
    public static void ClearCart(String cartId, String cartInfo){
        WebCart cartUpdate = [Select Id, Color_Info__c From WebCart Where Id =: cartId];
        cartUpdate.Color_Info__c = cartInfo;
        update cartUpdate;
    }
    
    public class ColorClass{
        String ProductSKU;
        String ColorName;
        String ColorCode;
        Decimal Quantity;
        
        public ColorClass(String vProductSKU, String vColorName, String vColorCode, Decimal vQuantity){
            ProductSKU = vProductSKU;
			ColorName = vColorName;            
            ColorCode = vColorCode;
            Quantity = vQuantity;
        }
        
        public override String toString()
        {
            String retString = '{\r\n \"ProductSKU\": \"' + ProductSKU + '\",\r\n\"ColorName\": \"' + ColorName + '\",\r\n\"ColorCode\": \"' + ColorCode + '\",\r\n\"Quantity\": ' + Quantity + '\r\n}';
            return retString;
        }
    }
}