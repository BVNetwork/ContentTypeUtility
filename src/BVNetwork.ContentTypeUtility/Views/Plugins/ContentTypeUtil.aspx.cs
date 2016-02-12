using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI.WebControls;
using EPiServer;
using EPiServer.Configuration;
using EPiServer.Core;
using EPiServer.DataAbstraction;
using EPiServer.PlugIn;
using EPiServer.ServiceLocation;

namespace BVNetwork.ContentTypeUtility.Views.Plugins
{
    [GuiPlugIn(DisplayName = "Content Type Utility",
        Description = "Utility for working with contenet types",
            Area = PlugInArea.AdminMenu,
              RequiredAccess = EPiServer.Security.AccessLevel.Administer,
            UrlFromModuleFolder = "Views/Plugins/ContentTypeUtil.aspx")]
    public class PageTypePlugin : SimplePage
    {
        public const string EpiserverConnectionstring = "EPiServerDB";

        protected Repeater rptPagetypes;
        protected Repeater rptBlockTypes;
        protected Repeater rptMediaTypes;
        protected Repeater rptOtherTypes;
        protected CheckBox chkShowHidden;
        protected Label lblResult;

        private void Page_Load(object sender, EventArgs e)
        {
            FillContentTypeList();
        }

        protected override void OnPreInit(EventArgs e)
        {
            // Switch to EPiServer UI masterpagefile.
            base.OnPreInit(e);
            Page.MasterPageFile = Settings.Instance.UIUrl + "MasterPages/EPiServerUI.Master";
        }

        private int _maxPageIDsToDisplay = 50;
        public int MaxPageIDsToDisplay
        {
            get
            {
                if (ConfigurationManager.AppSettings["EPnContentTypeUtilMaxPageIDsToDisplay"] != null)
                {
                    if (int.TryParse(ConfigurationManager.AppSettings["EPnContentTypeUtilMaxPageIDsToDisplay"], out _maxPageIDsToDisplay))
                        return _maxPageIDsToDisplay;
                }

                return _maxPageIDsToDisplay;
            }
            set { _maxPageIDsToDisplay = value; }
        }

        #region Web Form Designer generated code
        override protected void OnInit(EventArgs e)
        {
            //
            // CODEGEN: This call is required by the ASP.NET Web Form Designer.
            //
            InitializeComponent();
            base.OnInit(e);
        }

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.chkShowHidden.CheckedChanged += new System.EventHandler(this.chkShowHidden_CheckedChanged);
            this.Load += new System.EventHandler(this.Page_Load);

        }
        #endregion


        protected string GetPageName(int contentId)
        {
            ContentReference contentReference = new ContentReference(contentId);

            if (contentReference != ContentReference.EmptyReference)
            {
                return ServiceLocator.Current.GetInstance<IContentLoader>().Get<IContent>(contentReference).Name;
            }

            return "No content name found for content id " + contentId;

        }

        private void FillContentTypeList()
        {
            var contentTypeRepository = ServiceLocator.Current.GetInstance<IContentTypeRepository>();
            var contentTypes = contentTypeRepository.List().ToList();

            if (chkShowHidden.Checked == false)
            {
                // Remove all hidden ones
                for (int i = contentTypes.Count() - 1; i >= 0; i--)
                {
                    if (contentTypes[i].IsAvailable == false)
                        contentTypes.RemoveAt(i);
                }
            }
            rptPagetypes.DataSource = contentTypes.Where(x => x.ModelType != null && x.ModelType.IsSubclassOf(typeof(PageData)));
            rptBlockTypes.DataSource = contentTypes.Where(x => x.ModelType != null && x.ModelType.IsSubclassOf(typeof(BlockData))).ToList();
            rptMediaTypes.DataSource = contentTypes.Where(x => x.ModelType != null && x.ModelType.IsSubclassOf(typeof(MediaData)));

            rptBlockTypes.DataBind();
            rptMediaTypes.DataBind();
            rptPagetypes.DataBind();

            var otherTypes = contentTypes.Where(x => x.ModelType == null || !x.ModelType.IsSubclassOf(typeof(PageData))
                && !x.ModelType.IsSubclassOf(typeof(BlockData))
                && !x.ModelType.IsSubclassOf(typeof(MediaData)));
            if (otherTypes.Any())
            {
                rptOtherTypes.DataSource = otherTypes;
                rptOtherTypes.DataBind();
            }
            else
            {
                rptOtherTypes.Visible = false;
            }
        }

        private void chkShowHidden_CheckedChanged(object sender, EventArgs e)
        {
            // Refill
            FillContentTypeList();
        }

        /// <summary>
        /// Gets the number of pages for a pagetype.
        /// </summary>
        /// <param name="pageTypeId">Page type id</param>
        /// <returns>The number of pages used by the page type</returns>
        protected int GetNumberOfPagesForPageType(int pageTypeId)
        {
            const string query = "SELECT COUNT(*) AS PageCount FROM tblPage WHERE (fkPageTypeID = {0})";

            return GetNumberOfPagesForPageTypeFromDatabase(pageTypeId, query);
        }

        /// <summary>
        /// Gets the number of work pages for a page type.
        /// </summary>
        /// <param name="pageTypeId">Page type id</param>
        /// <returns></returns>
        public int GetNumberOfWorkPagesForPageType(int pageTypeId)
        {
            const string query = @"SELECT COUNT(*) AS PageCount FROM tblWorkPage 
							 INNER JOIN tblPage ON tblWorkPage.fkPageID = tblPage.pkID 
							 WHERE (tblPage.fkPageTypeID = {0})";

            return GetNumberOfPagesForPageTypeFromDatabase(pageTypeId, query);
        }

        public int GetNumberOfContentForContentTypeIncludeLanguageVersions(int contentTypeId)
        {
            const string query = @"SELECT COUNT(*) AS PageCount FROM tblWorkContent 
							 INNER JOIN tblPage ON tblWorkContent.fkContentID = tblPage.pkID 
							 WHERE (tblPage.fkPageTypeID = {0}) AND tblWorkContent.Status = 4";

            return GetNumberOfPagesForPageTypeFromDatabase(contentTypeId, query);
        }

        protected DataTable GetPageIdsForPageType(int pageTypeId)
        {
            const string query = "SELECT TOP ({0}) pkID FROM tblPage WHERE (fkPageTypeID = {1})";

            DataSet ds = GetIDsToPagesForPageTypeFromDatabase(pageTypeId, string.Format(query, MaxPageIDsToDisplay, pageTypeId));

            if (ds == null)
                return null;

            return ds.Tables[0];
        }

        /// <summary>
        /// Gets the number of pages a for page type from database.
        /// </summary>
        /// <param name="pageTypeId">Page type id to count pages for</param>
        /// <param name="query">Query to run against database</param>
        /// <returns></returns>
        private int GetNumberOfPagesForPageTypeFromDatabase(int pageTypeId, string query)
        {
            SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[EpiserverConnectionstring].ToString());
            SqlCommand cmd = conn.CreateCommand();
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = string.Format(query, pageTypeId);

            try
            {
                conn.Open();
                object pageCount = cmd.ExecuteScalar();
                conn.Close();

                return (int)pageCount;
            }
            catch (Exception ex)   // ignore missing columns in the database
            {
                lblResult.Text = ex.Message;
                lblResult.Visible = true;
            }
            finally
            {
                conn.Close();
            }

            return -1;
        }

        private DataSet GetIDsToPagesForPageTypeFromDatabase(int pageTypeId, string query)
        {
            SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[EpiserverConnectionstring].ToString());
            SqlCommand cmd = conn.CreateCommand();
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = string.Format(query, pageTypeId);

            try
            {
                DataSet ds = new DataSet();
                conn.Open();

                SqlDataAdapter adapter = new SqlDataAdapter(cmd);

                adapter.Fill(ds);
                return ds;
            }
            catch (Exception ex)   // ignore missing columns in the database
            {
                lblResult.Text = ex.Message;
                lblResult.Visible = true;
            }
            finally
            {
                conn.Close();
            }

            return null;
        }

        public PageType _mainPageType;

        public PageTypeCollection GetAvailablePageTypes(int id)
        {
            _mainPageType = PageType.Load(id);

            // Show all pagetypes, even not available in editmode
            if (chkShowHidden.Checked)
                return PageType.List();

            // Hide all pagetypes not available in editmode
            PageTypeCollection ptc = new PageTypeCollection();

            foreach (PageType pagetype in PageType.List())
            {
                if (pagetype.IsAvailable)
                    ptc.Add(pagetype);
            }

            return ptc;
        }

        protected void rptAvailablePageTypes_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            Repeater rpt = (Repeater)source;

            if (rpt != null)
            {
                ArrayList list = new ArrayList();

                foreach (RepeaterItem itm in rpt.Items)
                {
                    // Get ID of page type
                    string sID = ((Label)itm.FindControl("lblPageTypeID")).Text;

                    int id = int.Parse(sID);
                    CheckBox chk = (CheckBox)itm.FindControl("chkAvaliable");

                    if (chk.Checked)
                    {
                        list.Add(Convert.ToInt32(id));
                    }
                }

                int pagetypeid = int.Parse(e.CommandArgument.ToString());

                PageType mainPageType = PageType.Load(pagetypeid);

                if (mainPageType != null)
                {
                    //mainPageType.AllowedPageTypes =(int[])list.ToArray(typeof(Int32));
                    mainPageType.Save();
                }
            }
        }
    }
}
