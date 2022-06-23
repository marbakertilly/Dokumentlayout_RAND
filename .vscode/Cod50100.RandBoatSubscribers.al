codeunit 50148 RandBoatSubscribers
{



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Prepayments", 'OnBeforeInvoice', '', true, true)]
    local procedure "Sales-Post Prepayments_OnBeforeInvoice"
    (
        var SalesHeader: Record "Sales Header";
        var Handled: Boolean

    )
    var
        SalesLine: Record "Sales Line";
        OrdreFee: Decimal;
        NewPrepayAmount: Decimal;
        NewPrepayProcent: Decimal;
    begin

        if (SalesHeader."Currency Code" = '') then
            OrdreFee := 7450
        else
            OrdreFee := 1000;  //Skal angives dynamisk i sales setup
        if OrdreFee <> 0 then begin
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            if SalesLine.FindFirst() then
                repeat
                    if (SalesLine."Prepmt. Line Amount" >= OrdreFee) then begin

                        NewPrepayAmount := SalesLine."Prepmt. Line Amount" - OrdreFee;

                        //NewPrepayProcent := Round(((NewPrepayAmount / SalesLine.Amount) * 100), 0.01);

                        //SalesLine.validate(SalesLine."Prepayment %", NewPrepayProcent);
                        SalesLine.validate(SalesLine."Prepmt. Line Amount", NewPrepayAmount);

                        OrdreFee := 0;

                    end else begin
                        OrdreFee -= SalesLine."Prepmt. Line Amount";
                        SalesLine.validate(SalesLine."Prepayment %", 0);
                    end;
                    SalesLine.Modify();
                    if OrdreFee = 0 then
                        exit;
                until SalesLine.Next() = 0;
        End;



    end;




}
