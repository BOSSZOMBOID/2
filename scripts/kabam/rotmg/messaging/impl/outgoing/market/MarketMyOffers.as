package kabam.rotmg.messaging.impl.outgoing.market
{
   import flash.utils.IDataOutput;
   import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;
   
   public class MarketMyOffers extends OutgoingMessage
   {
       
      
      public function MarketMyOffers(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
      }
   }
}
