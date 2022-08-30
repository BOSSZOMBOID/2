package kabam.rotmg.messaging.impl.outgoing.talisman
{
   import flash.utils.IDataOutput;
   import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;
   
   public class TalismanEssenceAction extends OutgoingMessage
   {
      
      public static const ADD_ESSENCE:int = 0;
      
      public static const TIER_UP:int = 1;
      
      public static const ENABLE:int = 2;
      
      public static const DISABLE:int = 3;
       
      
      public var actionType_:int;
      
      public var type_:int;
      
      public var amount_:int;
      
      public function TalismanEssenceAction(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeByte(this.actionType_);
         param1.writeInt(this.type_);
         param1.writeInt(this.amount_);
      }
      
      override public function toString() : String
      {
         return formatToString("TALISMAN_ESSENCE_ACTION","actionType_","expectedCost_");
      }
   }
}
