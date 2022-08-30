package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   import kabam.rotmg.messaging.impl.data.FuelEngine;
   
   public class FuelEngineAction extends OutgoingMessage
   {
       
      
      public var myInv:Vector.<FuelEngine>;
      
      public function FuelEngineAction(param1:uint, param2:Function)
      {
         super(param1,param2);
         this.myInv = new Vector.<FuelEngine>();
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         var _loc2_:int = 0;
         param1.writeShort(this.myInv.length);
         _loc2_ = 0;
         while(_loc2_ < this.myInv.length)
         {
            param1.writeShort(this.myInv[_loc2_].objectType_);
            param1.writeInt(this.myInv[_loc2_].slotId_);
            param1.writeBoolean(this.myInv[_loc2_].included_);
            param1.writeInt(this.myInv[_loc2_].itemData_);
            _loc2_++;
         }
      }
      
      override public function toString() : String
      {
         return formatToString("ENGINE_FUEL_ACTION","myInventory_");
      }
   }
}
