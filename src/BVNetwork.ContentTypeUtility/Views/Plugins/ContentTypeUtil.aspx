<%@ Page Language="c#" CodeBehind="ContentTypeUtil.aspx.cs" AutoEventWireup="false"
    Inherits="BVNetwork.ContentTypeUtility.Views.Plugins.PageTypePlugin" %>

<%@ Import Namespace="EPiServer.Web.Routing" %>
<%@ Import Namespace="EPiServer.Core" %>
<%@ Import Namespace="EPiServer.Web" %>

<asp:Content runat="server" ContentPlaceHolderID="HeaderContentRegion">
    <link rel="Stylesheet" href="/App_Themes/Default/Styles/system.css" />
    <link rel="Stylesheet" href="/App_Themes/Default/Styles/toolbutton.css" />
    <style>
        .hidden {
            visibility: hidden;
            display: none;
        }

        td.datarow {
            border-bottom: 1px solid #dddddd;
        }

        td.commands {
            white-space: nowrap;
        }

        label {
            padding-left: 5px;
        }
    </style>
    <script type='text/javascript'> 
<!--
    function hide(elemName) {
        //For ie6 use document.all[elemname]
        document.getElementById(elemName).style.visibility = "hidden";
        document.getElementById(elemName).style.display = "none";

    }
    function show(elemName) {
        document.getElementById(elemName).style.visibility = "visible";
        document.getElementById(elemName).style.display = "inline";
    }
    function toggle(elemName) {
        if (document.getElementById(elemName).style.visibility == "visible")
            hide(elemName);
        else
            show(elemName);
    }
    </script>
</asp:Content>
                                    
<asp:Content runat="server" ContentPlaceHolderID="FullRegion">
    <div class="epi-contentContainer epi-padding">
        <div class="epi-contentArea">
            <h1 class="EP-prefix">Content type Utility</h1>
            <asp:CheckBox ID="chkShowHidden" AutoPostBack="True" runat="server" Text="Show hidden content types" />
            <asp:PlaceHolder runat="server" Visible='<%# lblResult.Visible %>'>
                <p>
                    <asp:Label Font-Bold="True" ForeColor="red" EnableViewState="False" ID="lblResult"
                        Visible="False" runat="server" />
                </p>
            </asp:PlaceHolder>
            <asp:Repeater ID="rptPagetypes" runat="server" EnableViewState="true">
                <HeaderTemplate>
                    <h2>Page types</h2>
                    <table class="epi-default">
                        <thead>
                            <tr>
                                <th>Visible</th>
                                <th>Name (id)</th>
                                <th>Number of items</th>
                                <th>Number of versions</th>
                                <th>Nr. of items (incl. language branches)</th>
                            </tr>
                        </thead>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td class="datarow">
                            <asp:CheckBox ID="chkVisible" EnableViewState="true" runat="server" Checked='<%# DataBinder.Eval(Container.DataItem, "IsAvailable") %>' Enabled="false" />
                        </td>
                        <td class="datarow">
                            <%# DataBinder.Eval(Container.DataItem, "Name") %>
                            
                            
                            &nbsp;(<asp:Label ID="lblPageTypeID" runat="server" EnableViewState="true" Text='<%# DataBinder.Eval(Container.DataItem, "ID") %>' />)
                            <asp:PlaceHolder runat="server" Visible='<%# GetNumberOfPagesForPageType((int)DataBinder.Eval(Container.DataItem, "ID")) > 0%>'>
                                <a
                                    href="#/"
                                    title='<%# GetNumberOfPagesForPageType((int)DataBinder.Eval(Container.DataItem, "ID")) %>'
                                    onclick="toggle('divpageids<%#DataBinder.Eval(Container.DataItem, "ID") %>')">[Show Content]</a>
                            </asp:PlaceHolder>
                            <div id='divpageids<%# DataBinder.Eval(Container.DataItem, "ID") %>' class="hidden">
                                <asp:Repeater runat="server" ID="pageids" DataSource='<%# GetPageIdsForPageType((int)DataBinder.Eval(Container.DataItem, "ID")) %>'>
                                    <HeaderTemplate>
                                        <div style="margin: 4px 0px 4px 0px; padding: 0px 0px 4px 8px; border: solid 1px #c0c0c0; background-color: #f8f8f8; width: 100%;">
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <a href='<%# UrlResolver.Current.GetUrl(new ContentReference((int)DataBinder.Eval(Container.DataItem, "pkID")))%>'
                                            title='<%# GetPageName((int)DataBinder.Eval(Container.DataItem, "pkID")) %>'
                                           target="_blank"><br /><%#GetPageName((int)DataBinder.Eval(Container.DataItem, "pkID"))%></a><span> <%# DataBinder.Eval(Container.DataItem, "pkId")%></span>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        </div>
                                    </FooterTemplate>
                                </asp:Repeater>
                            </div>
                        </td>
                        <td class="datarow">
                            <%# GetNumberOfPagesForPageType((int)DataBinder.Eval(Container.DataItem, "ID")) %>
                        </td>
                        <td class="datarow">
                            <%# GetNumberOfWorkPagesForPageType((int)DataBinder.Eval(Container.DataItem, "ID")) %>
                        </td>     
                            <td class="datarow">
                            <%# GetNumberOfContentForContentTypeIncludeLanguageVersions((int)DataBinder.Eval(Container.DataItem, "ID")) %>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </table>
                </FooterTemplate>
            </asp:Repeater>

            <asp:Repeater ID="rptBlockTypes" runat="server" EnableViewState="true">
                <HeaderTemplate>
                    <h2>Block types</h2>
                    <table class="epi-default">
                        <thead>
                            <tr>
                                <th>Visible</th>
                                <th>Name (id)</th>
                                <th>Number of items</th>
                                <th>Number of versions</th>
                            </tr>
                        </thead>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td class="datarow">
                            <asp:CheckBox ID="chkVisible" EnableViewState="true" runat="server" Checked='<%# DataBinder.Eval(Container.DataItem, "IsAvailable") %>' Enabled="false" />
                        </td>
                        <td class="datarow">
                            <%# DataBinder.Eval(Container.DataItem, "Name") %>
                            
                            
                            &nbsp;(<asp:Label ID="lblPageTypeID" runat="server" EnableViewState="true" Text='<%# DataBinder.Eval(Container.DataItem, "ID") %>' />)
                            <asp:PlaceHolder runat="server" Visible='<%# GetNumberOfPagesForPageType((int)DataBinder.Eval(Container.DataItem, "ID")) > 0%>'>
                                <a
                                    href="#/"
                                    title='<%# GetNumberOfPagesForPageType((int)DataBinder.Eval(Container.DataItem, "ID")) %>'
                                    onclick="toggle('divpageids<%#DataBinder.Eval(Container.DataItem, "ID") %>')">[Show Content]</a>
                            </asp:PlaceHolder>
                            <div id='divpageids<%# DataBinder.Eval(Container.DataItem, "ID") %>' class="hidden">
                                <asp:Repeater runat="server" ID="pageids" DataSource='<%# GetPageIdsForPageType((int)DataBinder.Eval(Container.DataItem, "ID")) %>'>
                                    <HeaderTemplate>
                                        <div style="margin: 4px 0px 4px 0px; padding: 0px 0px 4px 8px; border: solid 1px #c0c0c0; background-color: #f8f8f8; width: 100%;">
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                           <a href='<%# UrlResolver.Current.GetUrl(new ContentReference((int)DataBinder.Eval(Container.DataItem, "pkID")),null, new VirtualPathArguments() { ContextMode = ContextMode.Preview})%>'
                                            title='<%# GetPageName((int)DataBinder.Eval(Container.DataItem, "pkID")) %>'
                                           target="_blank"><br /><%#GetPageName((int)DataBinder.Eval(Container.DataItem, "pkID"))%></a><span> <%# DataBinder.Eval(Container.DataItem, "pkId")%></span>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        </div>
                                    </FooterTemplate>
                                </asp:Repeater>
                            </div>
                        </td>
                        <td class="datarow">
                            <%# GetNumberOfPagesForPageType((int)DataBinder.Eval(Container.DataItem, "ID")) %>
                        </td>
                        <td class="datarow">
                            <%# GetNumberOfWorkPagesForPageType((int)DataBinder.Eval(Container.DataItem, "ID")) %>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
               <asp:Repeater ID="rptMediaTypes" runat="server" EnableViewState="true">
                <HeaderTemplate>
                    <h2>Media types</h2>
                    <table class="epi-default">
                        <thead>
                            <tr>
                                <th>Visible</th>
                                <th>Name (id)</th>
                                <th>Number of items</th>
                                <th>Number of versions</th>
                            </tr>
                        </thead>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td class="datarow">
                            <asp:CheckBox ID="chkVisible" EnableViewState="true" runat="server" Checked='<%# DataBinder.Eval(Container.DataItem, "IsAvailable") %>' Enabled="false" />
                        </td>
                        <td class="datarow">
                            <%# DataBinder.Eval(Container.DataItem, "Name") %>
                            
                            
                            &nbsp;(<asp:Label ID="lblPageTypeID" runat="server" EnableViewState="true" Text='<%# DataBinder.Eval(Container.DataItem, "ID") %>' />)
                            <asp:PlaceHolder runat="server" Visible='<%# GetNumberOfPagesForPageType((int)DataBinder.Eval(Container.DataItem, "ID")) > 0%>'>
                                <a
                                    href="#/"
                                    title='<%# GetNumberOfPagesForPageType((int)DataBinder.Eval(Container.DataItem, "ID")) %>'
                                    onclick="toggle('divpageids<%#DataBinder.Eval(Container.DataItem, "ID") %>')">[Show Content]</a>
                            </asp:PlaceHolder>
                            <div id='divpageids<%# DataBinder.Eval(Container.DataItem, "ID") %>' class="hidden">
                                <asp:Repeater runat="server" ID="pageids" DataSource='<%# GetPageIdsForPageType((int)DataBinder.Eval(Container.DataItem, "ID")) %>'>
                                    <HeaderTemplate>
                                        <div style="margin: 4px 0px 4px 0px; padding: 0px 0px 4px 8px; border: solid 1px #c0c0c0; background-color: #f8f8f8; width: 100%;">
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                           <a href='<%# UrlResolver.Current.GetUrl(new ContentReference((int)DataBinder.Eval(Container.DataItem, "pkID")),null, new VirtualPathArguments() { ContextMode = ContextMode.Preview})%>'
                                            title='<%# GetPageName((int)DataBinder.Eval(Container.DataItem, "pkID")) %>'
                                           target="_blank"><br /><%#GetPageName((int)DataBinder.Eval(Container.DataItem, "pkID"))%></a><span> <%# DataBinder.Eval(Container.DataItem, "pkId")%></span>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        </div>
                                    </FooterTemplate>
                                </asp:Repeater>
                            </div>
                        </td>
                        <td class="datarow">
                            <%# GetNumberOfPagesForPageType((int)DataBinder.Eval(Container.DataItem, "ID")) %>
                        </td>
                        <td class="datarow">
                            <%# GetNumberOfWorkPagesForPageType((int)DataBinder.Eval(Container.DataItem, "ID")) %>
                        </td>                        <td class="datarow">
                            <%# GetNumberOfContentForContentTypeIncludeLanguageVersions((int)DataBinder.Eval(Container.DataItem, "ID")) %>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </table>
                </FooterTemplate>
            </asp:Repeater>

               <asp:Repeater ID="rptOtherTypes" runat="server" EnableViewState="true">
                <HeaderTemplate>
                    <h2>Other types</h2>
                    <table class="epi-default">
                        <thead>
                            <tr>
                                <th>Visible</th>
                                <th>Name (id)</th>
                                <th>Number of items</th>
                                <th>Number of versions</th>
                            </tr>
                        </thead>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td class="datarow">
                            <asp:CheckBox ID="chkVisible" EnableViewState="true" runat="server" Checked='<%# DataBinder.Eval(Container.DataItem, "IsAvailable") %>' Enabled="false" />
                        </td>
                        <td class="datarow">
                            <%# DataBinder.Eval(Container.DataItem, "Name") %>
                            
                            
                            &nbsp;(<asp:Label ID="lblPageTypeID" runat="server" EnableViewState="true" Text='<%# DataBinder.Eval(Container.DataItem, "ID") %>' />)
                            <asp:PlaceHolder runat="server" Visible='<%# GetNumberOfPagesForPageType((int)DataBinder.Eval(Container.DataItem, "ID")) > 0%>'>
                                <a
                                    href="#/"
                                    title='<%# GetNumberOfPagesForPageType((int)DataBinder.Eval(Container.DataItem, "ID")) %>'
                                    onclick="toggle('divpageids<%#DataBinder.Eval(Container.DataItem, "ID") %>')">[Show Content]</a>
                            </asp:PlaceHolder>
                            <div id='divpageids<%# DataBinder.Eval(Container.DataItem, "ID") %>' class="hidden">
                                <asp:Repeater runat="server" ID="pageids" DataSource='<%# GetPageIdsForPageType((int)DataBinder.Eval(Container.DataItem, "ID")) %>'>
                                    <HeaderTemplate>
                                        <div style="margin: 4px 0px 4px 0px; padding: 0px 0px 4px 8px; border: solid 1px #c0c0c0; background-color: #f8f8f8; width: 100%;">
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                           <a href='<%# UrlResolver.Current.GetUrl(new ContentReference((int)DataBinder.Eval(Container.DataItem, "pkID")),null, new VirtualPathArguments() { ContextMode = ContextMode.Preview})%>'
                                            title='<%# GetPageName((int)DataBinder.Eval(Container.DataItem, "pkID")) %>'
                                           target="_blank"><br /><%#GetPageName((int)DataBinder.Eval(Container.DataItem, "pkID"))%></a><span> <%# DataBinder.Eval(Container.DataItem, "pkId")%></span>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        </div>
                                    </FooterTemplate>
                                </asp:Repeater>
                            </div>
                        </td>
                        <td class="datarow">
                            <%# GetNumberOfPagesForPageType((int)DataBinder.Eval(Container.DataItem, "ID")) %>
                        </td>
                        <td class="datarow">
                            <%# GetNumberOfWorkPagesForPageType((int)DataBinder.Eval(Container.DataItem, "ID")) %>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </table>
                </FooterTemplate>
            </asp:Repeater>

           
           

        </div>
    </div>
</asp:Content>
