package kabam.rotmg.messaging.impl.data
{
   import flash.utils.IDataInput;
   
   public class MarketData
   {
       
      
      public var id_:int;
      
      public var itemType_:Number;
      
      public var sellerName_:String;
      
      public var sellerId_:int;
      
      public var currency_:int;
      
      public var price_:int;
      
      public var startTime_:int;
      
      public var timeLeft_:int;
      
      public var itemData_:String;
      
      public function MarketData()
      {
         super();
      }
      
      public function parseFromInput(param1:IDataInput) : void
      {
         this.id_ = param1.readInt();
         this.itemType_ = param1.readUnsignedShort();
         this.sellerName_ = param1.readUTF();
         this.sellerId_ = param1.readInt();
         this.currency_ = param1.readInt();
         this.price_ = param1.readInt();
         this.startTime_ = param1.readInt();
         this.timeLeft_ = param1.readInt();
         this.itemData_ = param1.readUTF();
      }
   }
}
