package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   import kabam.rotmg.messaging.impl.data.SlotObjectData;
   
   public class RenameItem extends OutgoingMessage
   {
       
      
      public var slot1:SlotObjectData;
      
      public var slot2:SlotObjectData;
      
      public var name:String;
      
      public function RenameItem(id:uint, callback:Function)
      {
         super(id,callback);
      }
      
      override public function writeToOutput(data:IDataOutput) : void
      {
         this.slot1.writeToOutput(data);
         this.slot2.writeToOutput(data);
         data.writeUTF(name);
      }
      
      override public function toString() : String
      {
         return "";
      }
   }
}
