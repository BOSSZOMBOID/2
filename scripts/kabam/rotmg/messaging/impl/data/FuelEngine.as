package kabam.rotmg.messaging.impl.data
{
   import flash.utils.IDataOutput;
   
   public class FuelEngine
   {
       
      
      public var objectType_:int;
      
      public var slotId_:int;
      
      public var included_:Boolean;
      
      public var itemData_:int;
      
      public function FuelEngine()
      {
         super();
      }
      
      public function parseFromInput(param1:IDataOutput) : void
      {
         param1.writeShort(this.objectType_);
         param1.writeInt(this.slotId_);
         param1.writeBoolean(this.included_);
         param1.writeInt(this.itemData_);
      }
      
      public function toString() : String
      {
         return "";
      }
   }
}
