package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class HomeDepotResult extends IncomingMessage
   {
       
      
      public var type_:int;
      
      public function HomeDepotResult(_arg1:uint, _arg2:Function)
      {
         super(_arg1,_arg2);
      }
      
      override public function parseFromInput(_arg1:IDataInput) : void
      {
         this.type_ = _arg1.readByte();
      }
      
      override public function toString() : String
      {
         return formatToString("HOMEDEPOTRESULT");
      }
   }
}
