package kabam.rotmg.messaging.impl.incoming.market
{
   import flash.utils.IDataInput;
   import kabam.rotmg.messaging.impl.incoming.IncomingMessage;
   
   public class MarketBuyResult extends IncomingMessage
   {
       
      
      public var code_:int;
      
      public var description_:String;
      
      public var offerId_:int;
      
      public function MarketBuyResult(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         this.code_ = param1.readInt();
         this.description_ = param1.readUTF();
         this.offerId_ = param1.readInt();
      }
   }
}
