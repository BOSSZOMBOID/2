package kabam.rotmg.messaging.impl.outgoing.market
{
   import flash.utils.IDataOutput;
   import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;
   
   public class MarketAdd extends OutgoingMessage
   {
       
      
      public var slots_:Vector.<int>;
      
      public var price_:int;
      
      public var currency_:int;
      
      public var hours_:int;
      
      public function MarketAdd(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeByte(this.slots_.length);
         var _loc2_:int = 0;
         while(_loc2_ < this.slots_.length)
         {
            param1.writeByte(this.slots_[_loc2_]);
            _loc2_++;
         }
         param1.writeInt(this.price_);
         param1.writeInt(this.currency_);
         param1.writeInt(this.hours_);
      }
   }
}
