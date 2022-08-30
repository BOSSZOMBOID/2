package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class AccountList extends IncomingMessage
   {
       
      
      public var accountListId_:int;
      
      public var accountIds_:Vector.<int>;
      
      public function AccountList(param1:uint, param2:Function)
      {
         this.accountIds_ = new Vector.<int>();
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         var _loc2_:int = 0;
         this.accountListId_ = param1.readInt();
         this.accountIds_.length = 0;
         var _loc3_:int = param1.readShort();
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            this.accountIds_.push(param1.readUTF());
            _loc2_++;
         }
      }
      
      override public function toString() : String
      {
         return formatToString("ACCOUNTLIST","accountListId_","accountIds_");
      }
   }
}
