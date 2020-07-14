namespace AIForms
{
    partial class Form1
    {
        /// <summary>
        /// 필수 디자이너 변수입니다.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 사용 중인 모든 리소스를 정리합니다.
        /// </summary>
        /// <param name="disposing">관리되는 리소스를 삭제해야 하면 true이고, 그렇지 않으면 false입니다.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form 디자이너에서 생성한 코드

        /// <summary>
        /// 디자이너 지원에 필요한 메서드입니다. 
        /// 이 메서드의 내용을 코드 편집기로 수정하지 마세요.
        /// </summary>
        private void InitializeComponent()
        {
            System.Windows.Forms.DataVisualization.Charting.ChartArea chartArea1 = new System.Windows.Forms.DataVisualization.Charting.ChartArea();
            System.Windows.Forms.DataVisualization.Charting.Legend legend1 = new System.Windows.Forms.DataVisualization.Charting.Legend();
            System.Windows.Forms.DataVisualization.Charting.Series series1 = new System.Windows.Forms.DataVisualization.Charting.Series();
            System.Windows.Forms.DataVisualization.Charting.ChartArea chartArea3 = new System.Windows.Forms.DataVisualization.Charting.ChartArea();
            System.Windows.Forms.DataVisualization.Charting.Legend legend3 = new System.Windows.Forms.DataVisualization.Charting.Legend();
            System.Windows.Forms.DataVisualization.Charting.Series series3 = new System.Windows.Forms.DataVisualization.Charting.Series();
            System.Windows.Forms.DataVisualization.Charting.ChartArea chartArea2 = new System.Windows.Forms.DataVisualization.Charting.ChartArea();
            System.Windows.Forms.DataVisualization.Charting.Legend legend2 = new System.Windows.Forms.DataVisualization.Charting.Legend();
            System.Windows.Forms.DataVisualization.Charting.Series series2 = new System.Windows.Forms.DataVisualization.Charting.Series();
            this.panel_data_graph_1 = new System.Windows.Forms.Panel();
            this.panel_data = new System.Windows.Forms.Panel();
            this.button_viewitem = new System.Windows.Forms.Button();
            this.textbox_viewindex = new System.Windows.Forms.TextBox();
            this.label_answer = new System.Windows.Forms.Label();
            this.label_data = new System.Windows.Forms.Label();
            this.textbox_answer = new System.Windows.Forms.TextBox();
            this.textbox_answeroffset = new System.Windows.Forms.TextBox();
            this.label_answeroffset = new System.Windows.Forms.Label();
            this.textbox_answerwidth = new System.Windows.Forms.TextBox();
            this.label_answerwidth = new System.Windows.Forms.Label();
            this.textbox_answerlength = new System.Windows.Forms.TextBox();
            this.label_answerlength = new System.Windows.Forms.Label();
            this.textbox_answerpath = new System.Windows.Forms.TextBox();
            this.label_answerpath = new System.Windows.Forms.Label();
            this.textbox_data = new System.Windows.Forms.TextBox();
            this.textbox_dataoffset = new System.Windows.Forms.TextBox();
            this.label_dataoffset = new System.Windows.Forms.Label();
            this.button_dataload = new System.Windows.Forms.Button();
            this.label_datawidth = new System.Windows.Forms.Label();
            this.label_datalength = new System.Windows.Forms.Label();
            this.label_datapath = new System.Windows.Forms.Label();
            this.textbox_datawidth = new System.Windows.Forms.TextBox();
            this.textbox_datalength = new System.Windows.Forms.TextBox();
            this.textbox_datapath = new System.Windows.Forms.TextBox();
            this.panel_network = new System.Windows.Forms.Panel();
            this.label_bias = new System.Windows.Forms.Label();
            this.label_weight = new System.Windows.Forms.Label();
            this.textbox_bias = new System.Windows.Forms.TextBox();
            this.textbox_weight = new System.Windows.Forms.TextBox();
            this.label_biasweightpath = new System.Windows.Forms.Label();
            this.textbox_biasweightpath = new System.Windows.Forms.TextBox();
            this.listview_network = new System.Windows.Forms.ListView();
            this.button_loadnetwork = new System.Windows.Forms.Button();
            this.textbox_networkpath = new System.Windows.Forms.TextBox();
            this.label_networkpath = new System.Windows.Forms.Label();
            this.tab_main = new System.Windows.Forms.TabControl();
            this.tabpage_data = new System.Windows.Forms.TabPage();
            this.tabpage_network = new System.Windows.Forms.TabPage();
            this.tabpage_train = new System.Windows.Forms.TabPage();
            this.panel_train = new System.Windows.Forms.Panel();
            this.textbox_exportpath = new System.Windows.Forms.TextBox();
            this.label_exportpath = new System.Windows.Forms.Label();
            this.label_traincount = new System.Windows.Forms.Label();
            this.textbox_traincount = new System.Windows.Forms.TextBox();
            this.button_train = new System.Windows.Forms.Button();
            this.tabpage_predict = new System.Windows.Forms.TabPage();
            this.panel_predict = new System.Windows.Forms.Panel();
            this.chart_predict = new System.Windows.Forms.DataVisualization.Charting.Chart();
            this.button_resetpaint = new System.Windows.Forms.Button();
            this.panel_paint = new System.Windows.Forms.Panel();
            this.button_predict = new System.Windows.Forms.Button();
            this.button_predictload = new System.Windows.Forms.Button();
            this.tabpage_test = new System.Windows.Forms.TabPage();
            this.button_test = new System.Windows.Forms.Button();
            this.chart_test_total = new System.Windows.Forms.DataVisualization.Charting.Chart();
            this.panel_data_graph_2 = new System.Windows.Forms.Panel();
            this.textbox_exepath = new System.Windows.Forms.TextBox();
            this.label_exepath = new System.Windows.Forms.Label();
            this.listview_test = new System.Windows.Forms.ListView();
            this.test_lvitem_seq = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.text_lvitem_answer = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.test_lvitem_result = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.test_lvitem_correct = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.chart_test_item = new System.Windows.Forms.DataVisualization.Charting.Chart();
            this.textbox_test = new System.Windows.Forms.TextBox();
            this.textbox_testcount = new System.Windows.Forms.TextBox();
            this.panel_data.SuspendLayout();
            this.panel_network.SuspendLayout();
            this.tab_main.SuspendLayout();
            this.tabpage_data.SuspendLayout();
            this.tabpage_network.SuspendLayout();
            this.tabpage_train.SuspendLayout();
            this.panel_train.SuspendLayout();
            this.tabpage_predict.SuspendLayout();
            this.panel_predict.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.chart_predict)).BeginInit();
            this.tabpage_test.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.chart_test_total)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.chart_test_item)).BeginInit();
            this.SuspendLayout();
            // 
            // panel_data_graph_1
            // 
            this.panel_data_graph_1.Location = new System.Drawing.Point(320, 145);
            this.panel_data_graph_1.Name = "panel_data_graph_1";
            this.panel_data_graph_1.Size = new System.Drawing.Size(400, 400);
            this.panel_data_graph_1.TabIndex = 0;
            // 
            // panel_data
            // 
            this.panel_data.Controls.Add(this.button_viewitem);
            this.panel_data.Controls.Add(this.textbox_viewindex);
            this.panel_data.Controls.Add(this.label_answer);
            this.panel_data.Controls.Add(this.label_data);
            this.panel_data.Controls.Add(this.textbox_answer);
            this.panel_data.Controls.Add(this.textbox_answeroffset);
            this.panel_data.Controls.Add(this.label_answeroffset);
            this.panel_data.Controls.Add(this.textbox_answerwidth);
            this.panel_data.Controls.Add(this.label_answerwidth);
            this.panel_data.Controls.Add(this.textbox_answerlength);
            this.panel_data.Controls.Add(this.label_answerlength);
            this.panel_data.Controls.Add(this.textbox_answerpath);
            this.panel_data.Controls.Add(this.label_answerpath);
            this.panel_data.Controls.Add(this.textbox_data);
            this.panel_data.Controls.Add(this.textbox_dataoffset);
            this.panel_data.Controls.Add(this.label_dataoffset);
            this.panel_data.Controls.Add(this.button_dataload);
            this.panel_data.Controls.Add(this.label_datawidth);
            this.panel_data.Controls.Add(this.label_datalength);
            this.panel_data.Controls.Add(this.label_datapath);
            this.panel_data.Controls.Add(this.textbox_datawidth);
            this.panel_data.Controls.Add(this.textbox_datalength);
            this.panel_data.Controls.Add(this.textbox_datapath);
            this.panel_data.Controls.Add(this.panel_data_graph_1);
            this.panel_data.Location = new System.Drawing.Point(6, 6);
            this.panel_data.Name = "panel_data";
            this.panel_data.Size = new System.Drawing.Size(730, 554);
            this.panel_data.TabIndex = 2;
            // 
            // button_viewitem
            // 
            this.button_viewitem.Location = new System.Drawing.Point(564, 119);
            this.button_viewitem.Name = "button_viewitem";
            this.button_viewitem.Size = new System.Drawing.Size(75, 23);
            this.button_viewitem.TabIndex = 27;
            this.button_viewitem.Text = "view item";
            this.button_viewitem.UseVisualStyleBackColor = true;
            this.button_viewitem.Click += new System.EventHandler(this.button_viewitem_Click);
            // 
            // textbox_viewindex
            // 
            this.textbox_viewindex.Location = new System.Drawing.Point(505, 120);
            this.textbox_viewindex.Name = "textbox_viewindex";
            this.textbox_viewindex.Size = new System.Drawing.Size(53, 21);
            this.textbox_viewindex.TabIndex = 26;
            // 
            // label_answer
            // 
            this.label_answer.AutoSize = true;
            this.label_answer.Location = new System.Drawing.Point(11, 448);
            this.label_answer.Name = "label_answer";
            this.label_answer.Size = new System.Drawing.Size(47, 12);
            this.label_answer.TabIndex = 23;
            this.label_answer.Text = "answer";
            // 
            // label_data
            // 
            this.label_data.AutoSize = true;
            this.label_data.Location = new System.Drawing.Point(10, 130);
            this.label_data.Name = "label_data";
            this.label_data.Size = new System.Drawing.Size(29, 12);
            this.label_data.TabIndex = 22;
            this.label_data.Text = "data";
            // 
            // textbox_answer
            // 
            this.textbox_answer.Location = new System.Drawing.Point(10, 463);
            this.textbox_answer.Multiline = true;
            this.textbox_answer.Name = "textbox_answer";
            this.textbox_answer.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.textbox_answer.Size = new System.Drawing.Size(300, 82);
            this.textbox_answer.TabIndex = 21;
            this.textbox_answer.WordWrap = false;
            // 
            // textbox_answeroffset
            // 
            this.textbox_answeroffset.Location = new System.Drawing.Point(385, 93);
            this.textbox_answeroffset.Name = "textbox_answeroffset";
            this.textbox_answeroffset.Size = new System.Drawing.Size(38, 21);
            this.textbox_answeroffset.TabIndex = 20;
            // 
            // label_answeroffset
            // 
            this.label_answeroffset.AutoSize = true;
            this.label_answeroffset.Location = new System.Drawing.Point(344, 99);
            this.label_answeroffset.Name = "label_answeroffset";
            this.label_answeroffset.Size = new System.Drawing.Size(35, 12);
            this.label_answeroffset.TabIndex = 19;
            this.label_answeroffset.Text = "offset";
            // 
            // textbox_answerwidth
            // 
            this.textbox_answerwidth.Location = new System.Drawing.Point(294, 93);
            this.textbox_answerwidth.Name = "textbox_answerwidth";
            this.textbox_answerwidth.Size = new System.Drawing.Size(44, 21);
            this.textbox_answerwidth.TabIndex = 18;
            // 
            // label_answerwidth
            // 
            this.label_answerwidth.AutoSize = true;
            this.label_answerwidth.Location = new System.Drawing.Point(207, 96);
            this.label_answerwidth.Name = "label_answerwidth";
            this.label_answerwidth.Size = new System.Drawing.Size(81, 12);
            this.label_answerwidth.TabIndex = 17;
            this.label_answerwidth.Text = "answer width";
            // 
            // textbox_answerlength
            // 
            this.textbox_answerlength.Location = new System.Drawing.Point(101, 93);
            this.textbox_answerlength.Name = "textbox_answerlength";
            this.textbox_answerlength.Size = new System.Drawing.Size(99, 21);
            this.textbox_answerlength.TabIndex = 16;
            // 
            // label_answerlength
            // 
            this.label_answerlength.AutoSize = true;
            this.label_answerlength.Location = new System.Drawing.Point(10, 96);
            this.label_answerlength.Name = "label_answerlength";
            this.label_answerlength.Size = new System.Drawing.Size(85, 12);
            this.label_answerlength.TabIndex = 15;
            this.label_answerlength.Text = "answer length";
            // 
            // textbox_answerpath
            // 
            this.textbox_answerpath.Location = new System.Drawing.Point(101, 66);
            this.textbox_answerpath.Name = "textbox_answerpath";
            this.textbox_answerpath.Size = new System.Drawing.Size(619, 21);
            this.textbox_answerpath.TabIndex = 14;
            // 
            // label_answerpath
            // 
            this.label_answerpath.AutoSize = true;
            this.label_answerpath.Location = new System.Drawing.Point(20, 69);
            this.label_answerpath.Name = "label_answerpath";
            this.label_answerpath.Size = new System.Drawing.Size(75, 12);
            this.label_answerpath.TabIndex = 13;
            this.label_answerpath.Text = "answer path";
            // 
            // textbox_data
            // 
            this.textbox_data.Font = new System.Drawing.Font("Courier New", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.textbox_data.Location = new System.Drawing.Point(10, 145);
            this.textbox_data.Multiline = true;
            this.textbox_data.Name = "textbox_data";
            this.textbox_data.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.textbox_data.Size = new System.Drawing.Size(300, 300);
            this.textbox_data.TabIndex = 12;
            this.textbox_data.WordWrap = false;
            // 
            // textbox_dataoffset
            // 
            this.textbox_dataoffset.Location = new System.Drawing.Point(423, 35);
            this.textbox_dataoffset.Name = "textbox_dataoffset";
            this.textbox_dataoffset.Size = new System.Drawing.Size(38, 21);
            this.textbox_dataoffset.TabIndex = 11;
            // 
            // label_dataoffset
            // 
            this.label_dataoffset.AutoSize = true;
            this.label_dataoffset.Location = new System.Drawing.Point(382, 38);
            this.label_dataoffset.Name = "label_dataoffset";
            this.label_dataoffset.Size = new System.Drawing.Size(35, 12);
            this.label_dataoffset.TabIndex = 10;
            this.label_dataoffset.Text = "offset";
            // 
            // button_dataload
            // 
            this.button_dataload.Location = new System.Drawing.Point(645, 119);
            this.button_dataload.Name = "button_dataload";
            this.button_dataload.Size = new System.Drawing.Size(75, 23);
            this.button_dataload.TabIndex = 9;
            this.button_dataload.Text = "load data";
            this.button_dataload.UseVisualStyleBackColor = true;
            this.button_dataload.Click += new System.EventHandler(this.button_dataload_Click);
            // 
            // label_datawidth
            // 
            this.label_datawidth.AutoSize = true;
            this.label_datawidth.Location = new System.Drawing.Point(207, 40);
            this.label_datawidth.Name = "label_datawidth";
            this.label_datawidth.Size = new System.Drawing.Size(63, 12);
            this.label_datawidth.TabIndex = 8;
            this.label_datawidth.Text = "data width";
            // 
            // label_datalength
            // 
            this.label_datalength.AutoSize = true;
            this.label_datalength.Location = new System.Drawing.Point(28, 38);
            this.label_datalength.Name = "label_datalength";
            this.label_datalength.Size = new System.Drawing.Size(67, 12);
            this.label_datalength.TabIndex = 7;
            this.label_datalength.Text = "data length";
            // 
            // label_datapath
            // 
            this.label_datapath.AutoSize = true;
            this.label_datapath.Location = new System.Drawing.Point(38, 13);
            this.label_datapath.Name = "label_datapath";
            this.label_datapath.Size = new System.Drawing.Size(57, 12);
            this.label_datapath.TabIndex = 6;
            this.label_datapath.Text = "data path";
            // 
            // textbox_datawidth
            // 
            this.textbox_datawidth.Location = new System.Drawing.Point(276, 35);
            this.textbox_datawidth.Name = "textbox_datawidth";
            this.textbox_datawidth.Size = new System.Drawing.Size(100, 21);
            this.textbox_datawidth.TabIndex = 4;
            // 
            // textbox_datalength
            // 
            this.textbox_datalength.Location = new System.Drawing.Point(101, 37);
            this.textbox_datalength.Name = "textbox_datalength";
            this.textbox_datalength.Size = new System.Drawing.Size(100, 21);
            this.textbox_datalength.TabIndex = 3;
            // 
            // textbox_datapath
            // 
            this.textbox_datapath.Location = new System.Drawing.Point(101, 10);
            this.textbox_datapath.Name = "textbox_datapath";
            this.textbox_datapath.Size = new System.Drawing.Size(619, 21);
            this.textbox_datapath.TabIndex = 2;
            // 
            // panel_network
            // 
            this.panel_network.Controls.Add(this.label_bias);
            this.panel_network.Controls.Add(this.label_weight);
            this.panel_network.Controls.Add(this.textbox_bias);
            this.panel_network.Controls.Add(this.textbox_weight);
            this.panel_network.Controls.Add(this.label_biasweightpath);
            this.panel_network.Controls.Add(this.textbox_biasweightpath);
            this.panel_network.Controls.Add(this.listview_network);
            this.panel_network.Controls.Add(this.button_loadnetwork);
            this.panel_network.Controls.Add(this.textbox_networkpath);
            this.panel_network.Controls.Add(this.label_networkpath);
            this.panel_network.Location = new System.Drawing.Point(6, 6);
            this.panel_network.Name = "panel_network";
            this.panel_network.Size = new System.Drawing.Size(731, 554);
            this.panel_network.TabIndex = 3;
            // 
            // label_bias
            // 
            this.label_bias.AutoSize = true;
            this.label_bias.Location = new System.Drawing.Point(320, 409);
            this.label_bias.Name = "label_bias";
            this.label_bias.Size = new System.Drawing.Size(29, 12);
            this.label_bias.TabIndex = 9;
            this.label_bias.Text = "bias";
            // 
            // label_weight
            // 
            this.label_weight.AutoSize = true;
            this.label_weight.Location = new System.Drawing.Point(320, 93);
            this.label_weight.Name = "label_weight";
            this.label_weight.Size = new System.Drawing.Size(42, 12);
            this.label_weight.TabIndex = 8;
            this.label_weight.Text = "weight";
            // 
            // textbox_bias
            // 
            this.textbox_bias.Location = new System.Drawing.Point(320, 424);
            this.textbox_bias.Multiline = true;
            this.textbox_bias.Name = "textbox_bias";
            this.textbox_bias.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.textbox_bias.Size = new System.Drawing.Size(408, 121);
            this.textbox_bias.TabIndex = 7;
            this.textbox_bias.WordWrap = false;
            // 
            // textbox_weight
            // 
            this.textbox_weight.Location = new System.Drawing.Point(320, 108);
            this.textbox_weight.Multiline = true;
            this.textbox_weight.Name = "textbox_weight";
            this.textbox_weight.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.textbox_weight.Size = new System.Drawing.Size(408, 298);
            this.textbox_weight.TabIndex = 6;
            this.textbox_weight.WordWrap = false;
            // 
            // label_biasweightpath
            // 
            this.label_biasweightpath.AutoSize = true;
            this.label_biasweightpath.Location = new System.Drawing.Point(7, 31);
            this.label_biasweightpath.Name = "label_biasweightpath";
            this.label_biasweightpath.Size = new System.Drawing.Size(98, 12);
            this.label_biasweightpath.TabIndex = 5;
            this.label_biasweightpath.Text = "bias weight path";
            // 
            // textbox_biasweightpath
            // 
            this.textbox_biasweightpath.Location = new System.Drawing.Point(111, 28);
            this.textbox_biasweightpath.Name = "textbox_biasweightpath";
            this.textbox_biasweightpath.Size = new System.Drawing.Size(617, 21);
            this.textbox_biasweightpath.TabIndex = 4;
            // 
            // listview_network
            // 
            this.listview_network.HideSelection = false;
            this.listview_network.Location = new System.Drawing.Point(7, 93);
            this.listview_network.MultiSelect = false;
            this.listview_network.Name = "listview_network";
            this.listview_network.Size = new System.Drawing.Size(307, 452);
            this.listview_network.TabIndex = 3;
            this.listview_network.UseCompatibleStateImageBehavior = false;
            this.listview_network.View = System.Windows.Forms.View.List;
            this.listview_network.SelectedIndexChanged += new System.EventHandler(this.listview_network_SelectedIndexChanged);
            // 
            // button_loadnetwork
            // 
            this.button_loadnetwork.Location = new System.Drawing.Point(612, 55);
            this.button_loadnetwork.Name = "button_loadnetwork";
            this.button_loadnetwork.Size = new System.Drawing.Size(116, 23);
            this.button_loadnetwork.TabIndex = 2;
            this.button_loadnetwork.Text = "load network";
            this.button_loadnetwork.UseVisualStyleBackColor = true;
            this.button_loadnetwork.Click += new System.EventHandler(this.button_loadnetwork_Click);
            // 
            // textbox_networkpath
            // 
            this.textbox_networkpath.Location = new System.Drawing.Point(111, 4);
            this.textbox_networkpath.Name = "textbox_networkpath";
            this.textbox_networkpath.Size = new System.Drawing.Size(617, 21);
            this.textbox_networkpath.TabIndex = 1;
            // 
            // label_networkpath
            // 
            this.label_networkpath.AutoSize = true;
            this.label_networkpath.Location = new System.Drawing.Point(28, 7);
            this.label_networkpath.Name = "label_networkpath";
            this.label_networkpath.Size = new System.Drawing.Size(77, 12);
            this.label_networkpath.TabIndex = 0;
            this.label_networkpath.Text = "network path";
            // 
            // tab_main
            // 
            this.tab_main.Controls.Add(this.tabpage_data);
            this.tab_main.Controls.Add(this.tabpage_network);
            this.tab_main.Controls.Add(this.tabpage_train);
            this.tab_main.Controls.Add(this.tabpage_predict);
            this.tab_main.Controls.Add(this.tabpage_test);
            this.tab_main.Location = new System.Drawing.Point(12, 12);
            this.tab_main.Name = "tab_main";
            this.tab_main.SelectedIndex = 0;
            this.tab_main.Size = new System.Drawing.Size(751, 594);
            this.tab_main.TabIndex = 4;
            // 
            // tabpage_data
            // 
            this.tabpage_data.Controls.Add(this.panel_data);
            this.tabpage_data.Location = new System.Drawing.Point(4, 22);
            this.tabpage_data.Name = "tabpage_data";
            this.tabpage_data.Padding = new System.Windows.Forms.Padding(3);
            this.tabpage_data.Size = new System.Drawing.Size(743, 568);
            this.tabpage_data.TabIndex = 1;
            this.tabpage_data.Text = "data";
            this.tabpage_data.UseVisualStyleBackColor = true;
            // 
            // tabpage_network
            // 
            this.tabpage_network.Controls.Add(this.panel_network);
            this.tabpage_network.Location = new System.Drawing.Point(4, 22);
            this.tabpage_network.Name = "tabpage_network";
            this.tabpage_network.Padding = new System.Windows.Forms.Padding(3);
            this.tabpage_network.Size = new System.Drawing.Size(743, 568);
            this.tabpage_network.TabIndex = 0;
            this.tabpage_network.Text = "network";
            this.tabpage_network.UseVisualStyleBackColor = true;
            // 
            // tabpage_train
            // 
            this.tabpage_train.Controls.Add(this.panel_train);
            this.tabpage_train.Location = new System.Drawing.Point(4, 22);
            this.tabpage_train.Name = "tabpage_train";
            this.tabpage_train.Padding = new System.Windows.Forms.Padding(3);
            this.tabpage_train.Size = new System.Drawing.Size(743, 568);
            this.tabpage_train.TabIndex = 2;
            this.tabpage_train.Text = "train";
            this.tabpage_train.UseVisualStyleBackColor = true;
            // 
            // panel_train
            // 
            this.panel_train.Controls.Add(this.textbox_exportpath);
            this.panel_train.Controls.Add(this.label_exportpath);
            this.panel_train.Controls.Add(this.label_traincount);
            this.panel_train.Controls.Add(this.textbox_traincount);
            this.panel_train.Controls.Add(this.button_train);
            this.panel_train.Location = new System.Drawing.Point(7, 7);
            this.panel_train.Name = "panel_train";
            this.panel_train.Size = new System.Drawing.Size(730, 555);
            this.panel_train.TabIndex = 0;
            // 
            // textbox_exportpath
            // 
            this.textbox_exportpath.Location = new System.Drawing.Point(73, 32);
            this.textbox_exportpath.Name = "textbox_exportpath";
            this.textbox_exportpath.Size = new System.Drawing.Size(654, 21);
            this.textbox_exportpath.TabIndex = 14;
            // 
            // label_exportpath
            // 
            this.label_exportpath.AutoSize = true;
            this.label_exportpath.Location = new System.Drawing.Point(3, 35);
            this.label_exportpath.Name = "label_exportpath";
            this.label_exportpath.Size = new System.Drawing.Size(68, 12);
            this.label_exportpath.TabIndex = 13;
            this.label_exportpath.Text = "export path";
            // 
            // label_traincount
            // 
            this.label_traincount.AutoSize = true;
            this.label_traincount.Location = new System.Drawing.Point(3, 9);
            this.label_traincount.Name = "label_traincount";
            this.label_traincount.Size = new System.Drawing.Size(64, 12);
            this.label_traincount.TabIndex = 12;
            this.label_traincount.Text = "train count";
            // 
            // textbox_traincount
            // 
            this.textbox_traincount.Location = new System.Drawing.Point(73, 4);
            this.textbox_traincount.Name = "textbox_traincount";
            this.textbox_traincount.Size = new System.Drawing.Size(64, 21);
            this.textbox_traincount.TabIndex = 11;
            // 
            // button_train
            // 
            this.button_train.Location = new System.Drawing.Point(143, 4);
            this.button_train.Name = "button_train";
            this.button_train.Size = new System.Drawing.Size(75, 23);
            this.button_train.TabIndex = 10;
            this.button_train.Text = "train";
            this.button_train.UseVisualStyleBackColor = true;
            this.button_train.Click += new System.EventHandler(this.button_train_Click);
            // 
            // tabpage_predict
            // 
            this.tabpage_predict.Controls.Add(this.panel_predict);
            this.tabpage_predict.Location = new System.Drawing.Point(4, 22);
            this.tabpage_predict.Name = "tabpage_predict";
            this.tabpage_predict.Padding = new System.Windows.Forms.Padding(3);
            this.tabpage_predict.Size = new System.Drawing.Size(743, 568);
            this.tabpage_predict.TabIndex = 3;
            this.tabpage_predict.Text = "predict";
            this.tabpage_predict.UseVisualStyleBackColor = true;
            // 
            // panel_predict
            // 
            this.panel_predict.Controls.Add(this.chart_predict);
            this.panel_predict.Controls.Add(this.button_resetpaint);
            this.panel_predict.Controls.Add(this.panel_paint);
            this.panel_predict.Controls.Add(this.button_predict);
            this.panel_predict.Controls.Add(this.button_predictload);
            this.panel_predict.Location = new System.Drawing.Point(7, 7);
            this.panel_predict.Name = "panel_predict";
            this.panel_predict.Size = new System.Drawing.Size(730, 555);
            this.panel_predict.TabIndex = 0;
            // 
            // chart_predict
            // 
            chartArea1.Name = "ChartArea1";
            this.chart_predict.ChartAreas.Add(chartArea1);
            legend1.Name = "Legend1";
            this.chart_predict.Legends.Add(legend1);
            this.chart_predict.Location = new System.Drawing.Point(285, 58);
            this.chart_predict.Name = "chart_predict";
            series1.ChartArea = "ChartArea1";
            series1.ChartType = System.Windows.Forms.DataVisualization.Charting.SeriesChartType.Pie;
            series1.IsValueShownAsLabel = true;
            series1.IsXValueIndexed = true;
            series1.Legend = "Legend1";
            series1.Name = "answer";
            series1.XValueMember = "Name";
            series1.YValueMembers = "Count";
            this.chart_predict.Series.Add(series1);
            this.chart_predict.Size = new System.Drawing.Size(438, 256);
            this.chart_predict.TabIndex = 12;
            this.chart_predict.Text = "result";
            // 
            // button_resetpaint
            // 
            this.button_resetpaint.Location = new System.Drawing.Point(488, 9);
            this.button_resetpaint.Name = "button_resetpaint";
            this.button_resetpaint.Size = new System.Drawing.Size(75, 23);
            this.button_resetpaint.TabIndex = 11;
            this.button_resetpaint.Text = "reset paint";
            this.button_resetpaint.UseVisualStyleBackColor = true;
            this.button_resetpaint.Click += new System.EventHandler(this.button_resetpaint_Click);
            // 
            // panel_paint
            // 
            this.panel_paint.BackColor = System.Drawing.Color.White;
            this.panel_paint.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.panel_paint.Location = new System.Drawing.Point(23, 58);
            this.panel_paint.Name = "panel_paint";
            this.panel_paint.Size = new System.Drawing.Size(256, 256);
            this.panel_paint.TabIndex = 10;
            this.panel_paint.MouseDown += new System.Windows.Forms.MouseEventHandler(this.panel_paint_MouseDown);
            this.panel_paint.MouseMove += new System.Windows.Forms.MouseEventHandler(this.panel_paint_MouseMove);
            this.panel_paint.MouseUp += new System.Windows.Forms.MouseEventHandler(this.panel_paint_MouseUp);
            // 
            // button_predict
            // 
            this.button_predict.Location = new System.Drawing.Point(648, 9);
            this.button_predict.Name = "button_predict";
            this.button_predict.Size = new System.Drawing.Size(75, 23);
            this.button_predict.TabIndex = 9;
            this.button_predict.Text = "predict";
            this.button_predict.UseVisualStyleBackColor = true;
            this.button_predict.Click += new System.EventHandler(this.button_predict_Click);
            // 
            // button_predictload
            // 
            this.button_predictload.Location = new System.Drawing.Point(569, 9);
            this.button_predictload.Name = "button_predictload";
            this.button_predictload.Size = new System.Drawing.Size(75, 23);
            this.button_predictload.TabIndex = 8;
            this.button_predictload.Text = "load";
            this.button_predictload.UseVisualStyleBackColor = true;
            // 
            // tabpage_test
            // 
            this.tabpage_test.Controls.Add(this.textbox_testcount);
            this.tabpage_test.Controls.Add(this.textbox_test);
            this.tabpage_test.Controls.Add(this.chart_test_item);
            this.tabpage_test.Controls.Add(this.listview_test);
            this.tabpage_test.Controls.Add(this.button_test);
            this.tabpage_test.Controls.Add(this.chart_test_total);
            this.tabpage_test.Controls.Add(this.panel_data_graph_2);
            this.tabpage_test.Location = new System.Drawing.Point(4, 22);
            this.tabpage_test.Name = "tabpage_test";
            this.tabpage_test.Padding = new System.Windows.Forms.Padding(3);
            this.tabpage_test.Size = new System.Drawing.Size(743, 568);
            this.tabpage_test.TabIndex = 4;
            this.tabpage_test.Text = "test";
            this.tabpage_test.UseVisualStyleBackColor = true;
            // 
            // button_test
            // 
            this.button_test.Location = new System.Drawing.Point(112, 538);
            this.button_test.Name = "button_test";
            this.button_test.Size = new System.Drawing.Size(625, 21);
            this.button_test.TabIndex = 14;
            this.button_test.Text = "test";
            this.button_test.UseVisualStyleBackColor = true;
            this.button_test.Click += new System.EventHandler(this.button_test_Click);
            // 
            // chart_test_total
            // 
            chartArea3.Name = "ChartArea1";
            this.chart_test_total.ChartAreas.Add(chartArea3);
            legend3.Name = "Legend1";
            this.chart_test_total.Legends.Add(legend3);
            this.chart_test_total.Location = new System.Drawing.Point(313, 312);
            this.chart_test_total.Name = "chart_test_total";
            series3.ChartArea = "ChartArea1";
            series3.ChartType = System.Windows.Forms.DataVisualization.Charting.SeriesChartType.Pie;
            series3.IsValueShownAsLabel = true;
            series3.IsXValueIndexed = true;
            series3.Legend = "Legend1";
            series3.Name = "answer";
            series3.XValueMember = "Name";
            series3.YValueMembers = "Count";
            this.chart_test_total.Series.Add(series3);
            this.chart_test_total.Size = new System.Drawing.Size(211, 200);
            this.chart_test_total.TabIndex = 13;
            this.chart_test_total.Text = "result";
            // 
            // panel_data_graph_2
            // 
            this.panel_data_graph_2.Location = new System.Drawing.Point(6, 6);
            this.panel_data_graph_2.Name = "panel_data_graph_2";
            this.panel_data_graph_2.Size = new System.Drawing.Size(300, 300);
            this.panel_data_graph_2.TabIndex = 1;
            // 
            // textbox_exepath
            // 
            this.textbox_exepath.Location = new System.Drawing.Point(72, 606);
            this.textbox_exepath.Name = "textbox_exepath";
            this.textbox_exepath.Size = new System.Drawing.Size(687, 21);
            this.textbox_exepath.TabIndex = 6;
            // 
            // label_exepath
            // 
            this.label_exepath.AutoSize = true;
            this.label_exepath.Location = new System.Drawing.Point(12, 609);
            this.label_exepath.Name = "label_exepath";
            this.label_exepath.Size = new System.Drawing.Size(54, 12);
            this.label_exepath.TabIndex = 5;
            this.label_exepath.Text = "exe path";
            // 
            // listview_test
            // 
            this.listview_test.Columns.AddRange(new System.Windows.Forms.ColumnHeader[] {
            this.test_lvitem_seq,
            this.text_lvitem_answer,
            this.test_lvitem_result,
            this.test_lvitem_correct});
            this.listview_test.FullRowSelect = true;
            this.listview_test.HideSelection = false;
            this.listview_test.Location = new System.Drawing.Point(313, 7);
            this.listview_test.MultiSelect = false;
            this.listview_test.Name = "listview_test";
            this.listview_test.Size = new System.Drawing.Size(424, 299);
            this.listview_test.TabIndex = 15;
            this.listview_test.UseCompatibleStateImageBehavior = false;
            this.listview_test.View = System.Windows.Forms.View.Details;
            this.listview_test.SelectedIndexChanged += new System.EventHandler(this.listview_test_SelectedIndexChanged);
            // 
            // test_lvitem_seq
            // 
            this.test_lvitem_seq.Text = "seq";
            // 
            // text_lvitem_answer
            // 
            this.text_lvitem_answer.Text = "answer";
            // 
            // test_lvitem_result
            // 
            this.test_lvitem_result.Text = "result";
            // 
            // test_lvitem_correct
            // 
            this.test_lvitem_correct.Text = "correct";
            // 
            // chart_test_item
            // 
            chartArea2.Name = "ChartArea1";
            this.chart_test_item.ChartAreas.Add(chartArea2);
            legend2.Name = "Legend1";
            this.chart_test_item.Legends.Add(legend2);
            this.chart_test_item.Location = new System.Drawing.Point(3, 312);
            this.chart_test_item.Name = "chart_test_item";
            series2.ChartArea = "ChartArea1";
            series2.ChartType = System.Windows.Forms.DataVisualization.Charting.SeriesChartType.Pie;
            series2.IsValueShownAsLabel = true;
            series2.IsXValueIndexed = true;
            series2.Legend = "Legend1";
            series2.Name = "answer";
            series2.XValueMember = "Name";
            series2.YValueMembers = "Count";
            this.chart_test_item.Series.Add(series2);
            this.chart_test_item.Size = new System.Drawing.Size(303, 200);
            this.chart_test_item.TabIndex = 16;
            this.chart_test_item.Text = "result";
            // 
            // textbox_test
            // 
            this.textbox_test.Location = new System.Drawing.Point(530, 312);
            this.textbox_test.Multiline = true;
            this.textbox_test.Name = "textbox_test";
            this.textbox_test.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.textbox_test.Size = new System.Drawing.Size(207, 200);
            this.textbox_test.TabIndex = 17;
            this.textbox_test.WordWrap = false;
            // 
            // textbox_testcount
            // 
            this.textbox_testcount.Location = new System.Drawing.Point(6, 538);
            this.textbox_testcount.Name = "textbox_testcount";
            this.textbox_testcount.Size = new System.Drawing.Size(100, 21);
            this.textbox_testcount.TabIndex = 18;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(773, 653);
            this.Controls.Add(this.textbox_exepath);
            this.Controls.Add(this.label_exepath);
            this.Controls.Add(this.tab_main);
            this.Name = "Form1";
            this.Text = "AIForms";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.Shown += new System.EventHandler(this.Form1_Shown);
            this.panel_data.ResumeLayout(false);
            this.panel_data.PerformLayout();
            this.panel_network.ResumeLayout(false);
            this.panel_network.PerformLayout();
            this.tab_main.ResumeLayout(false);
            this.tabpage_data.ResumeLayout(false);
            this.tabpage_network.ResumeLayout(false);
            this.tabpage_train.ResumeLayout(false);
            this.panel_train.ResumeLayout(false);
            this.panel_train.PerformLayout();
            this.tabpage_predict.ResumeLayout(false);
            this.panel_predict.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.chart_predict)).EndInit();
            this.tabpage_test.ResumeLayout(false);
            this.tabpage_test.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.chart_test_total)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.chart_test_item)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Panel panel_data_graph_1;
        private System.Windows.Forms.Panel panel_data;
        private System.Windows.Forms.Label label_datawidth;
        private System.Windows.Forms.Label label_datalength;
        private System.Windows.Forms.Label label_datapath;
        private System.Windows.Forms.TextBox textbox_datawidth;
        private System.Windows.Forms.TextBox textbox_datalength;
        private System.Windows.Forms.TextBox textbox_datapath;
        private System.Windows.Forms.Button button_dataload;
        private System.Windows.Forms.TextBox textbox_dataoffset;
        private System.Windows.Forms.Label label_dataoffset;
        private System.Windows.Forms.TextBox textbox_data;
        private System.Windows.Forms.Label label_answerpath;
        private System.Windows.Forms.TextBox textbox_answerpath;
        private System.Windows.Forms.TextBox textbox_answerwidth;
        private System.Windows.Forms.Label label_answerwidth;
        private System.Windows.Forms.TextBox textbox_answerlength;
        private System.Windows.Forms.Label label_answerlength;
        private System.Windows.Forms.TextBox textbox_answeroffset;
        private System.Windows.Forms.Label label_answeroffset;
        private System.Windows.Forms.Label label_answer;
        private System.Windows.Forms.Label label_data;
        private System.Windows.Forms.TextBox textbox_answer;
        private System.Windows.Forms.Button button_viewitem;
        private System.Windows.Forms.TextBox textbox_viewindex;
        private System.Windows.Forms.Panel panel_network;
        private System.Windows.Forms.TextBox textbox_networkpath;
        private System.Windows.Forms.Label label_networkpath;
        private System.Windows.Forms.Button button_loadnetwork;
        private System.Windows.Forms.ListView listview_network;
        private System.Windows.Forms.Label label_bias;
        private System.Windows.Forms.Label label_weight;
        private System.Windows.Forms.TextBox textbox_bias;
        private System.Windows.Forms.TextBox textbox_weight;
        private System.Windows.Forms.Label label_biasweightpath;
        private System.Windows.Forms.TextBox textbox_biasweightpath;
        private System.Windows.Forms.TabControl tab_main;
        private System.Windows.Forms.TabPage tabpage_network;
        private System.Windows.Forms.TabPage tabpage_data;
        private System.Windows.Forms.TabPage tabpage_train;
        private System.Windows.Forms.Panel panel_train;
        private System.Windows.Forms.TabPage tabpage_predict;
        private System.Windows.Forms.Panel panel_predict;
        private System.Windows.Forms.Button button_predict;
        private System.Windows.Forms.Button button_predictload;
        private System.Windows.Forms.Button button_resetpaint;
        private System.Windows.Forms.Panel panel_paint;
        private System.Windows.Forms.DataVisualization.Charting.Chart chart_predict;
        private System.Windows.Forms.Label label_traincount;
        private System.Windows.Forms.TextBox textbox_traincount;
        private System.Windows.Forms.Button button_train;
        private System.Windows.Forms.TextBox textbox_exepath;
        private System.Windows.Forms.Label label_exepath;
        private System.Windows.Forms.TextBox textbox_exportpath;
        private System.Windows.Forms.Label label_exportpath;
        private System.Windows.Forms.TabPage tabpage_test;
        private System.Windows.Forms.Panel panel_data_graph_2;
        private System.Windows.Forms.DataVisualization.Charting.Chart chart_test_total;
        private System.Windows.Forms.Button button_test;
        private System.Windows.Forms.ListView listview_test;
        private System.Windows.Forms.ColumnHeader test_lvitem_seq;
        private System.Windows.Forms.ColumnHeader text_lvitem_answer;
        private System.Windows.Forms.ColumnHeader test_lvitem_result;
        private System.Windows.Forms.ColumnHeader test_lvitem_correct;
        private System.Windows.Forms.DataVisualization.Charting.Chart chart_test_item;
        private System.Windows.Forms.TextBox textbox_test;
        private System.Windows.Forms.TextBox textbox_testcount;
    }
}

