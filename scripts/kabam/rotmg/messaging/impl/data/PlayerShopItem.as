package kabam.rotmg.messaging.impl.data
{
   import flash.utils.IDataInput;
   
   public class PlayerShopItem
   {
       
      
      public var id:int;
      
      public var itemId:int;
      
      public var price:int;
      
      public var insertTime:int;
      
      public var count:int;
      
      public var isLast:Boolean;
      
      public function PlayerShopItem()
      {
         super();
      }
      
      public function parseFromInput(rdr:IDataInput) : void
      {
         this.id = rdr.readUnsignedInt();
         this.itemId = rdr.readUnsignedShort();
         this.price = rdr.readInt();
         this.insertTime = rdr.readInt();
         this.count = rdr.readInt();
         this.isLast = rdr.readBoolean();
      }
   }
}
