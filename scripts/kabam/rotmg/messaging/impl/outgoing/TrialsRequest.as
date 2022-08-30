package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   
   public class TrialsRequest extends OutgoingMessage
   {
       
      
      public var sendBoss_:int;
      
      public function TrialsRequest(val:uint, func:Function)
      {
         super(val,func);
      }
      
      override public function writeToOutput(iDataOutput:IDataOutput) : void
      {
         iDataOutput.writeInt(this.sendBoss_);
      }
      
      override public function toString() : String
      {
         return formatToString("TRIALSREQUEST","sendBoss_");
      }
   }
}
