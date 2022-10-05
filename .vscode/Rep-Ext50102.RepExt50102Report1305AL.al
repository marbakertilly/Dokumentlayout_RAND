reportextension 50102 "Rep-Ext50102.Report1305.AL" extends "Standard Sales - Order Conf."
{

    dataset
    {
        add(Header)
        {
            column(DimensionSetID; "Dimension Set ID") { }
            Column(Dim3; DimCodeArray[3]) { }
            Column(Dim4; DimCodeArray[4]) { }
            Column(Dim5; DimCodeArray[5]) { }
            Column(Dim6; DimCodeArray[6]) { }
            column(Currency_Code; "Currency Code") { }
            column(Shortcut_Dimension_1_Code; "Shortcut Dimension 1 Code") { }
            column(Shortcut_Dimension_2_Code; "Shortcut Dimension 2 Code") { }
            column(TarrifNo; Tariff_No) { }
            column(TotalSubTotal2; TotalSubTotal2) { }
            column(TotalVATAmount2; TotalAmountVAT2) { }
            column(TotalAmountIncludingVAT2; TotalAmountIncludingVAT2) { }
            column(PrepaymentAmountHeader; PrepaymentAmountHeader) { }
            column(PrepaymentAmountHeader2; PrepaymentAmountHeader2) { }
            column(OrderFeePaid; OrderFeePaid) { }
            column(PrepaymentPaid; PrepaymentPaid) { }
            column(TotalItemAmount; TotalItemAmount) { }


        }

        modify(Header)
        {
            trigger OnAfterAfterGetRecord()
            var
            begin
                DimSetEntry.setrange(DimSetEntry."Dimension Set ID", Header."Dimension Set ID");
                DimSetEntry.SetFilter(DimSetEntry."Global Dimension No.", '<>0');
                if DimSetEntry.FindFirst() then
                    repeat
                        DimCodeArray[DimSetEntry."Global Dimension No."] := DimSetEntry."Dimension Value Code";
                    until DimSetEntry.Next() = 0;
                SalesLines.setrange(SalesLines."Document No.", Header."No.");
                SalesLines.SetRange(SalesLines."Document Type", Header."Document Type");
                SalesLines.Setrange(SalesLines.Type, SalesLines.Type::Item);
                if SalesLines.FindFirst() THEN
                    repeat
                        if Itemrec.get(SalesLines."No.") then
                            Tariff_No := itemrec."Tariff No.";
                        TotalItemAmount += SalesLines.Amount;
                    Until SalesLines.Next() = 0;
                SalesInvHeader.SetRange(SalesInvHeader.Closed, true);
                SalesInvHeader.SetRange(SalesInvHeader."Prepayment Invoice", true);
                SalesInvHeader.SetRange(SalesInvHeader."Prepayment Order No.", "No.");
                if SalesInvHeader.FindFirst() then
                    repeat
                        SalesInvLines.setrange(SalesInvLines."Document No.", SalesInvHeader."No.");
                        if SalesInvLines.FindFirst() then
                            repeat
                                PrepaydAmount -= SalesInvLines.Amount;
                                Prepayd_Amount_incl_vat -= SalesInvLines."Amount Including VAT";
                            until SalesInvLines.Next() = 0;
                    until SalesInvHeader.next = 0;
                PrepaymentAmountHeader := PrepaydAmount;
                PrepaymentAmountHeader2 := PrepaymentAmountHeader * -1;
                If (Header."Currency Code" = '') then
                    OrderFee := -7450
                else
                    OrderFee := -1000;

                if (PrepaydAmount <= OrderFee) then
                    OrderFeePaid := 1
                else
                    OrderFeePaid := 0;
                if PrepaydAmount < OrderFee then
                    PrepaymentPaid := 1
                else
                    PrepaymentPaid := 0;

            end;

        }
        add(Line)
        {
            column(Line_Discount_Amount; "Line Discount Amount") { }
            column(Line_Amount; "Line Amount") { }
        }
        modify(Line)
        {
            trigger OnBeforeAfterGetRecord()
            begin
                if not (Line.Type = Line.Type::Item) then
                    Line."No." := '';
                TotalSubTotal2 += "Line Amount";
                TotalInvDiscAmount2 -= "Inv. Discount Amount";
                TotalAmount2 += Amount;
                TotalAmountVAT2 += ("Amount Including VAT" - Amount);
                // TotalAmountIncludingVAT2 += "Amount Including VAT";
                TotalPaymentDiscOnVAT2 += -("Line Amount" - "Inv. Discount Amount" - "Amount Including VAT");
            end;
        }
        addafter(Line)
        {
            dataitem(PrepayLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                MaxIteration = 1;
                column(Prepayd_Amount; PrepaydAmount)
                {
                    AutoFormatExpression = Header."Currency Code";
                    AutoFormatType = 1;
                }
                column(Prepayd_Amount_incl_vat; PrepaydAmount)
                {
                    AutoFormatExpression = Header."Currency Code";
                    AutoFormatType = 1;
                }
                column(IsPrepay_Line; IsPrepayLine) { }
                column(PrepayDescr_Label; PrepayDescr_Lbl) { }

                trigger OnPreDataItem()
                begin
                    TotalSubTotal2 += PrepaydAmount;
                    TotalAmountVAT2 += (Prepayd_Amount_incl_vat - PrepaydAmount);
                    IsPrepayLine := 1;
                    //  TotalAmountIncludingVAT2 := TotalSubTotal2 + TotalAmountVAT2;

                end;
            }
        }

    }

    var
        DimSetEntry: Record "Dimension Set Entry";
        DimCodeArray: Array[6] of Code[20];
        Tariff_No: Code[20];
        SalesLines: Record "Sales Line";
        TempSalesLine: Record "Sales Line" temporary;
        ItemRec: Record Item;

        SalesInvHeader: Record "Sales Invoice Header";
        SalesInvLines: Record "Sales Invoice Line";

        PrepaydAmount: Decimal;
        PrepayLineNo: Integer;
        IsPrepayLine: Integer;

        PrepayDescr_Lbl: Label 'Prepayd amount';
        Prepayd_Amount_incl_vat: Decimal;

        TotalSubTotal2: Decimal;
        TotalInvDiscAmount2: Decimal;
        TotalAmount2: Decimal;
        TotalAmountVAT2: Decimal;
        TotalPaymentDiscOnVAT2: Decimal;
        TotalAmountIncludingVAT2: Decimal;
        PrepaymentAmountHeader: Decimal;
        PrepaymentAmountHeader2: Decimal;
        OrderFeePaid: Integer;
        PrepaymentPaid: Integer;
        TotalItemAmount: Decimal;
        OrderFee: Decimal;


}
