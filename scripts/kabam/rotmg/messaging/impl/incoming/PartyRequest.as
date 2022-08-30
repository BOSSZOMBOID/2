package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class PartyRequest extends IncomingMessage
   {
       
      
      public var from_:String;
      
      public var name_:String;
      
      public function PartyRequest(_arg1:uint, _arg2:Function)
      {
         super(_arg1,_arg2);
      }
      
      override public function parseFromInput(_arg1:IDataInput) : void
      {
         this.from_ = _arg1.readUTF();
         this.name_ = _arg1.readUTF();
      }
      
      override public function toString() : String
      {
         return formatToString("PARTYREQUEST","from_","name_");
      }
   }
}
