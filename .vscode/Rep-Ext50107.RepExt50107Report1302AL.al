reportextension 50107 "Rep-Ext50107.Report1302.AL" extends "Standard Sales - Pro Forma Inv"
{
    dataset
    {
        add(Header)
        {
            column(DimensionSet9ID; "Dimension Set ID") { }
            Column(Dim3; DimCodeArray[3]) { }
            Column(Dim4; DimCodeArray[4]) { }
            Column(Dim5; DimCodeArray[5]) { }
            Column(Dim6; DimCodeArray[6]) { }
            column(Currency_Code; "Currency Code") { }
            column(Shortcut_Dimension_1_Code; "Shortcut Dimension 1 Code") { }
            column(Shortcut_Dim9e9nsion_2_Code; "Shortcut Dimension 2 Code") { }
            column(TarrifNo; Tariff_No) { }
            column(VATRegistrationNo; "VAT Registration No.") { }
            column(PricesIncludingVAT; "Prices Including VAT") { }
            column(TotalSubTotal; TotalSubTotal) { }
            column(TotalSubTotalMinusInvoiceDiscount; TotalSubTotal + TotalInvDiscAmount) { }
            column(TotalInvoiceDiscountAmount; TotalInvDiscAmount) { }
            column(TotalExcludingVATText; TotalExclVATText) { }
            column(TotalIncludingVATText; TotalInclVATText) { }
            column(Subtotal_Lbl; SubtotalLbl) { }
            column(InvoiceDiscountAmount_Lbl; InvDiscountAmtLbl) { }
            column(LineAmountAfterInvoiceDiscount_Lbl; LineAmtAfterInvDiscLbl) { }
            column(CompanyBankName; CompanyBankName) { }
            column(CompanyIBAN; CompanyIBAN) { }
            column(CompanySWIFT; CompanySWIFT) { }
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
                if SalesLines.FindFirst() THEN Begin
                    if Itemrec.get(SalesLines."No.") then
                        Tariff_No := itemrec."Tariff No.";
                End;
                SalesLines.Setrange(SalesLines.Type);
                if SalesLines.FindFirst() THEN
                    repeat
                        TotalSubTotal += SalesLines."Line Amount";
                        TotalInvDiscAmount -= SalesLines."Inv. Discount Amount";
                    until SalesLines.Next() = 0;
                FormatDocument.SetTotalLabels("Currency Code", TotalText, TotalInclVATText, TotalExclVATText);
                CompanyInfo2.get();
                CompanyVATRegNo := CompanyInfo2."VAT Registration No.";
                CompanyBankName := CompanyInfo2."Bank Name";
                CompanyIBAN := CompanyInfo2.IBAN;
                CompanySWIFT := CompanyInfo2."SWIFT Code";
            end;
        }
        add(Line)
        {
            column(Line_Discount_Amount; "Line Discount Amount") { }
            column(Line_Amount; "Line Amount") { }
            column(ItemNo_Line; "No.") { }
            column(LineDiscountPercentText_Line; LineDiscountPctText) { }
            column(VATPct_Line; FormattedVATPct) { }
            Column(LineDescription; Description) { }
            column(Type_Line; Type) { }
        }
        modify(Line)
        {


            trigger OnBeforeAfterGetRecord()
            begin
                if "Line Discount %" = 0 then
                    LineDiscountPctText := ''
                else
                    LineDiscountPctText := StrSubstNo('%1%', -Round("Line Discount %", 0.1));
                FormatDocument.SetSalesLine(Line, FormattedQuantity, FormattedUnitPrice, FormattedVATPct, FormattedLineAmount2);
                DummyTxt := FormattedVATPct;

            end;
        }
        addafter(Line)
        {
            dataitem(RandBoatsLoop; "Sales Line")
            {
                DataItemTableView = SORTING("Document Type", "Document No.", "Line No.");
                DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                column(ShowLine; ShowLine) { }
                column(Line_Discount_Amount2; "Line Discount Amount") { }
                column(Line_Amount2; "Line Amount") { }
                column(ItemNo_Line2; "No.") { }
                column(LineDiscountPercentText_Line2; LineDiscountPctText) { }
                column(VATPct_Line2; FormattedVATPct) { }
                Column(LineDescription2; Description) { }
                column(Type_Line2; Type) { }
                column(LineNo2; "Line No.") { }

                trigger OnAfterGetRecord()
                begin
                    case Type of
                        Type::Item:
                            ShowLine := 1;
                        Type::"G/L Account":
                            ShowLine := 2
                        else
                            ShowLine := 3;
                    end;
                end;
            }
        }
    }


    var
        DimSetEntry: Record "Dimension Set Entry";
        DimCodeArray: Array[6] of Code[20];
        Tariff_No: Code[20];
        SalesLines: Record "Sales Line";
        ItemRec: Record Item;

        Dummy: Code[20];
        LineDiscountPctText: Text;
        TotalSubTotal: Decimal;

        TotalInvDiscAmount: Decimal;

        TotalExclVATText: Text[50];
        TotalInclVATText: Text[50];

        TotalText: Text[50];
        SubtotalLbl: Label 'Subtotal';
        InvDiscountAmtLbl: Label 'Invoice Discount';
        InvNoLbl: Label 'Order No.';
        LineAmtAfterInvDiscLbl: Label 'Payment Discount on VAT';
        FormatDocument: Codeunit "Format Document";

        FormattedVATPct: Text;
        FormattedUnitPrice: Text;
        FormattedQuantity: Text;

        FormattedLineAmount2: Text;

        DummyTxt: Text;

        CompanyInfo2: record "Company Information";

        CompanyVATRegNo: Text[100];

        CompanyIBAN: Code[50];

        CompanyBankName: Text[100];
        CompanySWIFT: Code[20];

        ShowLine: Integer;

        AutoFormat2: Codeunit "Auto Format";

}
