package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class LootNotification extends IncomingMessage
   {
       
      
      public var item:int;
      
      public function LootNotification(_arg1:uint, _arg2:Function)
      {
         super(_arg1,_arg2);
      }
      
      override public function parseFromInput(_arg1:IDataInput) : void
      {
         this.item = _arg1.readInt();
      }
      
      override public function toString() : String
      {
         return formatToString("LOOTNOTIFICATION","item");
      }
   }
}