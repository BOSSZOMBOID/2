package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class SendAspectData extends IncomingMessage
   {
       
      
      public var anubisStacks:int;
      
      public function SendAspectData(_arg1:uint, _arg2:Function)
      {
         super(_arg1,_arg2);
      }
      
      override public function parseFromInput(_arg1:IDataInput) : void
      {
         this.anubisStacks = _arg1.readInt();
      }
      
      override public function toString() : String
      {
         return "";
      }
   }
}
