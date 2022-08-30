package kabam.rotmg.messaging.impl.data
{
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   
   public class SlotObjectData
   {
       
      
      public var objectId_:int;
      
      public var slotId_:int;
      
      public var itemData_:String;
      
      public function SlotObjectData()
      {
         super();
      }
      
      public function parseFromInput(_arg1:IDataInput) : void
      {
         this.objectId_ = _arg1.readInt();
         this.slotId_ = _arg1.readUnsignedByte();
         this.itemData_ = _arg1.readUTF();
      }
      
      public function writeToOutput(_arg1:IDataOutput) : void
      {
         _arg1.writeInt(this.objectId_);
         _arg1.writeByte(this.slotId_);
         _arg1.writeUTF(this.itemData_);
      }
      
      public function toString() : String
      {
         return "objectId_: " + this.objectId_ + " slotId_: " + this.slotId_ + " itemData: " + this.itemData_;
      }
   }
}
