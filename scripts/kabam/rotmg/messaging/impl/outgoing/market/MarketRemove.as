package kabam.rotmg.messaging.impl.outgoing.market
{
   import flash.utils.IDataOutput;
   import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;
   
   public class MarketRemove extends OutgoingMessage
   {
       
      
      public var id_:int;
      
      public function MarketRemove(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeInt(this.id_);
      }
   }
}
