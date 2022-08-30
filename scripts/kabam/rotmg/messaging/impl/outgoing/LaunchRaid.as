package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   
   public class LaunchRaid extends OutgoingMessage
   {
       
      
      public var raidId_:int;
      
      public var ultra_:Boolean;
      
      public function LaunchRaid(_arg_1:uint, _arg_2:Function)
      {
         super(_arg_1,_arg_2);
      }
      
      override public function writeToOutput(_arg1:IDataOutput) : void
      {
         _arg1.writeInt(this.raidId_);
         _arg1.writeBoolean(this.ultra_);
      }
      
      override public function toString() : String
      {
         return formatToString("LAUNCHRAID","raidId_","ultra_");
      }
   }
}
