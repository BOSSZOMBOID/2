package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class ShowTrials extends IncomingMessage
   {
       
      
      public var openDialog:Boolean;
      
      public function ShowTrials(_arg_1:uint, _arg_2:Function)
      {
         super(_arg_1,_arg_2);
      }
      
      override public function parseFromInput(_arg_1:IDataInput) : void
      {
         this.openDialog = _arg_1.readBoolean();
      }
      
      override public function toString() : String
      {
         return formatToString("SHOWTRIALS","openDialog");
      }
   }
}
