package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   import kabam.rotmg.messaging.impl.data.PlayerShopItem;
   
   public class MarketResult extends IncomingMessage
   {
      
      public static const MARKET_ERROR:int = 0;
      
      public static const MARKET_SUCCESS:int = 1;
      
      public static const MARKET_REQUEST_RESULT:int = 2;
       
      
      public var commandId:int;
      
      public var message:String;
      
      public var error:Boolean;
      
      public var items:Vector.<PlayerShopItem>;
      
      public function MarketResult(packetId:uint, callback:Function)
      {
         this.items = new Vector.<PlayerShopItem>();
         super(packetId,callback);
      }
      
      override public function parseFromInput(rdr:IDataInput) : void
      {
         var len:int = 0;
         var i:int = 0;
         var item:* = null;
         commandId = rdr.readByte();
         loop1:
         switch(int(commandId))
         {
            case 0:
            case 1:
               message = rdr.readUTF();
               error = commandId == 0;
               break;
            case 2:
               this.items.length = 0;
               len = rdr.readInt();
               i = 0;
               while(true)
               {
                  if(i >= len)
                  {
                     break loop1;
                  }
                  item = new PlayerShopItem();
                  item.parseFromInput(rdr);
                  this.items.push(item);
                  i++;
               }
         }
      }
   }
}
