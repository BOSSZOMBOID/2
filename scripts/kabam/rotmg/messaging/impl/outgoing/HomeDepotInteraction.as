package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   
   public class HomeDepotInteraction extends OutgoingMessage
   {
       
      
      public var type_:int;
      
      public var name_:String;
      
      public var stack_:int;
      
      public function HomeDepotInteraction(_arg1:uint, _arg2:Function)
      {
         super(_arg1,_arg2);
         this.name_ = new String();
      }
      
      override public function writeToOutput(_arg1:IDataOutput) : void
      {
         _arg1.writeByte(this.type_);
         _arg1.writeUTF(this.name_);
         _arg1.writeInt(this.stack_);
      }
      
      override public function toString() : String
      {
         return formatToString("HOMEDEPOTINTERACTION");
      }
   }
}
