package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class BuyResult extends IncomingMessage
   {
      
      public static const SUCCESS_BRID:int = 0;
      
      public static const DIALOG_BRID:int = 1;
       
      
      public var result_:int;
      
      public var resultString_:String;
      
      public function BuyResult(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         this.result_ = param1.readInt();
         this.resultString_ = param1.readUTF();
      }
      
      override public function toString() : String
      {
         return formatToString("BUYRESULT","result_","resultString_");
      }
   }
}
