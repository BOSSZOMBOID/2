package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   
   public class Load extends OutgoingMessage
   {
       
      
      public var charId_:int;
      
      public function Load(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeInt(this.charId_);
      }
      
      override public function toString() : String
      {
         return formatToString("LOAD","charId_");
      }
   }
}
