package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   import kabam.rotmg.messaging.impl.data.MarketOffer;
   
   public class MarketCommand extends OutgoingMessage
   {
      
      public static const REQUEST_MY_ITEMS:int = 0;
      
      public static const ADD_OFFER:int = 1;
      
      public static const REMOVE_OFFER:int = 2;
      
      public static const REQUEST_ALL_ITEMS:int = 3;
       
      
      public var commandId:int;
      
      public var offerIds:Vector.<uint>;
      
      public var newOffers:Vector.<MarketOffer>;
      
      public function MarketCommand(packetId:uint, callback:Function)
      {
         super(packetId,callback);
      }
      
      override public function writeToOutput(wtr:IDataOutput) : void
      {
         wtr.writeByte(commandId);
         loop2:
         switch(int(commandId))
         {
            case 0:
            case 3:
               break;
            case 1:
               wtr.writeInt(newOffers.length);
               for each(var offer in newOffers)
               {
                  offer.writeToOutput(wtr);
               }
               break;
            case 2:
               wtr.writeInt(offerIds.length);
               var _loc7_:int = 0;
               var _loc6_:* = offerIds;
               while(true)
               {
                  for each(var offerId in _loc6_)
                  {
                     wtr.writeUnsignedInt(offerId);
                  }
                  break loop2;
               }
         }
      }
   }
}
