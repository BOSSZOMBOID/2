package kabam.rotmg.messaging.impl.data
{
   import flash.utils.IDataOutput;
   
   public class ForgeItem
   {
       
      
      public var objectType_:int;
      
      public var slotId_:int;
      
      public var included_:Boolean;
      
      public function ForgeItem()
      {
         super();
      }
      
      public function parseFromInput(param1:IDataOutput) : void
      {
         param1.writeShort(this.objectType_);
         param1.writeInt(this.slotId_);
         param1.writeBoolean(this.included_);
      }
      
      public function toString() : String
      {
         return "";
      }
   }
}
