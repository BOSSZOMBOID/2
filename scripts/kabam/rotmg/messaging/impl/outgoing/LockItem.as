package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   import kabam.rotmg.messaging.impl.data.SlotObjectData;
   
   public class LockItem extends OutgoingMessage
   {
       
      
      public var slotObject_:SlotObjectData;
      
      public function LockItem(id:uint, callback:Function)
      {
         slotObject_ = new SlotObjectData();
         super(id,callback);
      }
      
      override public function writeToOutput(_arg1:IDataOutput) : void
      {
         this.slotObject_.writeToOutput(_arg1);
      }
      
      override public function toString() : String
      {
         return "";
      }
   }
}
