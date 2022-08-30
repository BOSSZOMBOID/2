package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   
   public class UsePotion extends OutgoingMessage
   {
       
      
      public var itemId_:int;
      
      public function UsePotion(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeInt(this.itemId_);
      }
      
      override public function toString() : String
      {
         return formatToString("USEPOTION","itemId_");
      }
   }
}
