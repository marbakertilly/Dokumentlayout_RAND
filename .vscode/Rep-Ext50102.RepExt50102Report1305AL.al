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
            end;
        }
        add(Line)
        {
            column(Line_Discount_Amount; "Line Discount Amount") { }
        }
    }
    var
        DimSetEntry: Record "Dimension Set Entry";
        DimCodeArray: Array[6] of Code[20];
        Tariff_No: Code[20];
        SalesLines: Record "Sales Line";
        ItemRec: Record Item;

}
