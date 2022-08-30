package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   
   public class PotionStorageInteraction extends OutgoingMessage
   {
       
      
      public var itemId_:int;
      
      public var action_:int;
      
      public var type_:int;
      
      public function PotionStorageInteraction(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeByte(this.type_);
         param1.writeByte(this.action_);
      }
      
      override public function toString() : String
      {
         return formatToString("PotionStorageInteraction","action_","type_");
      }
   }
}
