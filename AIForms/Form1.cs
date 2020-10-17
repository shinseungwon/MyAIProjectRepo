using MyAIWrapper;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Text;
using System.Threading;
using System.Windows.Forms;

namespace AIForms
{

    public partial class Form1 : Form
    {
        byte[] data;
        List<byte[]> dataSplit;

        byte[] answer;
        List<byte[]> answerSplit;

        string dataPath;
        int dataLength;
        int dataWidth;
        int dataCount;

        string answerPath;
        int answerLength;
        int answerWidth;
        int answerCount;

        float[][] bias;
        float[][] weight;

        int[] weightWidth;

        byte[][] pixels;

        bool clicked = false;

        List<List<float>> test_res;

        public Form1()
        {
            InitializeComponent();
        }

        //before load
        private void Form1_Load(object sender, EventArgs e)
        {

        }

        //after load
        private void Form1_Shown(object sender, EventArgs e)
        {
            //textbox_datapath.Text = @"C:\Users\ssw90\source\repos\MyAIFramework\mnist\batch-images.idx3-ubyte";
            textbox_datapath.Text = @"C:\Users\ssw90\source\repos\MyAIProjectRepo\MyAIFramework\mnist\train-images.idx3-ubyte";
            textbox_datalength.Text = "784";
            textbox_datawidth.Text = "28";
            textbox_dataoffset.Text = "16";

            textbox_answerpath.Text = @"C:\Users\ssw90\source\repos\MyAIProjectRepo\MyAIFramework\mnist\labels.idx1-ubyte";
            textbox_answerlength.Text = "10";
            textbox_answerwidth.Text = "10";
            textbox_answeroffset.Text = "0";

            textbox_networkpath.Text = @"C:\Users\ssw90\source\repos\MyAIProjectRepo\MyAIFramework\mnist\spec.txt";
            textbox_biasweightpath.Text = @"C:\Users\ssw90\source\repos\MyAIProjectRepo\MyAIFramework\mnist\weight-export.txt";

            textbox_exepath.Text = @"C:\Users\ssw90\source\repos\MyAIProjectRepo\MyAIFramework\x64\Debug\MyAIFramework.exe";

            textbox_exportpath.Text = @"C:\Users\ssw90\source\repos\MyAIProjectRepo\MyAIFramework\mnist\weight-export-4";

            textbox_testcount.Text = "100";

            loadData();
            loadNetwork();

            int paint_size = panel_paint.Width;
            pixels = new byte[paint_size][];
            for (int i = 0; i < paint_size; i++)
            {
                pixels[i] = new byte[paint_size];
            }
        }

        private void button_dataload_Click(object sender, EventArgs e)
        {
            loadData();
        }

        private void button_viewitem_Click(object sender, EventArgs e)
        {
            draw(panel_data_graph_1, int.Parse(textbox_viewindex.Text));
        }

        private void button_loadnetwork_Click(object sender, EventArgs e)
        {
            loadNetwork();
        }

        private void loadData()
        {
            textbox_data.Clear();
            textbox_answer.Clear();

            dataPath = textbox_datapath.Text;
            dataLength = int.Parse(textbox_datalength.Text);
            dataWidth = int.Parse(textbox_datawidth.Text);

            answerPath = textbox_answerpath.Text;
            answerLength = int.Parse(textbox_answerlength.Text);
            answerWidth = int.Parse(textbox_answerwidth.Text);

            data = File.ReadAllBytes(dataPath);
            dataSplit = new List<byte[]>();

            answer = File.ReadAllBytes(answerPath);
            answerSplit = new List<byte[]>();

            int i, j, idx;

            dataCount = data.Length / dataLength;
            int dataOffset = int.Parse(textbox_dataoffset.Text);
            byte[] dataTemp = new byte[dataLength];

            idx = 0;
            for (i = dataOffset; i < data.Length; i++)
            {
                dataTemp[idx] = data[i];
                idx++;

                if ((i - dataOffset) % dataLength == dataLength - 1)
                {
                    dataSplit.Add(dataTemp);
                    dataTemp = new byte[dataLength];
                    idx = 0;
                }
            }

            answerCount = answer.Length / answerLength;
            int answerOffset = int.Parse(textbox_answeroffset.Text);
            byte[] answerTemp = new byte[answerLength];

            idx = 0;
            for (i = answerOffset; i < answer.Length; i++)
            {
                answerTemp[idx] = answer[i];
                idx++;

                if ((i - answerOffset) % answerLength == answerLength - 1)
                {
                    answerSplit.Add(answerTemp);
                    answerTemp = new byte[answerLength];
                    idx = 0;
                }
            }

            if (dataCount != answerCount)
            {
                Console.WriteLine("Data/Answer doesn't match");
            }

            Console.WriteLine("Data size : " + data.Length + " byte");
            Console.WriteLine("Data count : " + dataCount);

            Console.WriteLine("Answer size : " + answer.Length + " byte");
            Console.WriteLine("Answer count : " + answerCount);
        }

        private void draw(Panel panel, int selectedIndex)
        {
            Console.WriteLine("Item " + selectedIndex + " selected");

            Graphics graphics_graph = panel.CreateGraphics();
            graphics_graph.Clear(Color.White);
            StringBuilder sbData = new StringBuilder();
            StringBuilder sbAnswer = new StringBuilder();

            int panelWidth = panel.Width;
            byte[] targetData = dataSplit[selectedIndex];
            int i, x, y, pixelSize = panelWidth / dataWidth;

            for (i = 0; i < targetData.Length; i++)
            {
                x = i % dataWidth * pixelSize;
                y = i / dataWidth * pixelSize;
                graphics_graph.FillRectangle(new SolidBrush(Color.FromArgb(targetData[i], targetData[i], targetData[i])), x, y, pixelSize, pixelSize);
                sbData.Append(targetData[i].ToString("X2") + " ");
                if (i % dataWidth == dataWidth - 1)
                {
                    sbData.Append("\r\n");
                }
            }
            textbox_data.Text = sbData.ToString();

            byte[] targetAnswer = answerSplit[selectedIndex];

            for (i = 0; i < targetAnswer.Length; i++)
            {
                sbAnswer.Append(targetAnswer[i].ToString("X2") + " ");
                if (i % answerWidth == answerWidth - 1)
                {
                    sbAnswer.Append("\r\n");
                }
            }
            textbox_answer.Text = sbAnswer.ToString();

            int maxAns, maxAnsIdx;

            maxAns = -1;
            maxAnsIdx = -1;
            for (i = 0; i < answerLength; i++)
            {
                if (answerSplit[selectedIndex][i] > maxAns)
                {
                    maxAns = answerSplit[selectedIndex][i];
                    maxAnsIdx = i;
                }
            }

            Console.WriteLine("Max idx : " + maxAnsIdx);
        }

        private void loadNetwork()
        {
            string networkPath = textbox_networkpath.Text;
            string biasWeightPath = textbox_biasweightpath.Text;
            string network = File.ReadAllText(networkPath);
            byte[] biasweight = File.ReadAllBytes(biasWeightPath);
            string[] layers = network.Split(new string[] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries);
            weightWidth = new int[layers.Length];
            bias = new float[layers.Length][];
            weight = new float[layers.Length][];

            int i, j, seq = 0, ws, bs;
            ListViewItem lvi;
            StringBuilder sb = new StringBuilder();
            for (i = 0; i < layers.Length; i++)
            {
                string[] line = layers[i].Split(' ');
                int type = int.Parse(line[0]);
                if (type == 1)
                {
                    lvi = new ListViewItem("Affine\n(" + line[1] + " * " + line[2] + ")");
                    listview_network.Items.Add(lvi);
                    bs = int.Parse(line[1]);
                    ws = bs * int.Parse(line[2]);
                    bias[i] = new float[bs];
                    weight[i] = new float[ws];
                    weightWidth[i] = int.Parse(line[1]);

                    for (j = 0; j < ws; j++)
                    {
                        weight[i][j] = BitConverter.ToSingle(biasweight, seq);
                        seq += 4;
                    }
                    for (j = 0; j < bs; j++)
                    {
                        bias[i][j] = BitConverter.ToSingle(biasweight, seq);
                        seq += 4;
                    }
                }
                else if (type == 2)
                {
                    lvi = new ListViewItem("Convolution\n(" + line[1] + " * " + line[1] + " - " + line[2] + " * " + line[2] + ")");
                    listview_network.Items.Add(lvi);
                    bs = 1;
                    ws = int.Parse(line[2]);
                    ws *= ws;
                    bias[i] = new float[bs];
                    weight[i] = new float[ws];
                    weightWidth[i] = int.Parse(line[2]);

                    for (j = 0; j < ws; j++)
                    {
                        weight[i][j] = BitConverter.ToSingle(biasweight, seq);
                        seq += 4;
                    }
                    for (j = 0; j < bs; j++)
                    {
                        bias[i][j] = BitConverter.ToSingle(biasweight, seq);
                        seq += 4;
                    }

                }
                else if (type == 3)
                {
                    lvi = new ListViewItem("Pooling\n(" + line[1] + " * " + line[1] + " - " + line[2] + " * " + line[2] + ")");
                    listview_network.Items.Add(lvi);
                }
                else
                {
                    Console.WriteLine("wrong layer type : " + type);
                }
            }
        }

        private void listview_network_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (listview_network.SelectedItems.Count == 1)
            {
                int idx = listview_network.SelectedItems[0].Index, i;
                if (weightWidth[idx] > 0)
                {
                    float[] w = weight[idx];
                    float[] b = bias[idx];

                    StringBuilder sb = new StringBuilder();
                    for (i = 0; i < w.Length; i++)
                    {
                        if (i % weightWidth[idx] == 0 && i > 0)
                        {
                            sb.Append("\r\n");
                        }
                        sb.Append(w[i].ToString("0.0000") + " ");
                    }
                    textbox_weight.Text = sb.ToString();

                    sb.Clear();
                    for (i = 0; i < b.Length; i++)
                    {
                        sb.Append(w[i].ToString("0.0000") + " ");
                    }
                    textbox_bias.Text = sb.ToString();
                }
            }
            else
            {
                textbox_weight.Clear();
                textbox_bias.Clear();
            }
        }

        private void panel_paint_MouseMove(object sender, MouseEventArgs e)
        {
            int xpos = e.Location.X;
            int ypos = e.Location.Y;

            if (clicked
                && xpos >= 0 && xpos < panel_paint.Width
                && ypos >= 0 && ypos < panel_paint.Height)
            {
                int paint_size = panel_paint.Width;
                Graphics g = panel_paint.CreateGraphics();
                g.FillRectangle(new SolidBrush(Color.FromArgb(0, 0, 0)), xpos, ypos, 16, 16);
                pixels[ypos][xpos] = 1;
            }
        }

        private void panel_paint_MouseDown(object sender, MouseEventArgs e)
        {
            clicked = true;
        }

        private void panel_paint_MouseUp(object sender, MouseEventArgs e)
        {
            clicked = false;
        }

        private void button_resetpaint_Click(object sender, EventArgs e)
        {
            Graphics g = panel_paint.CreateGraphics();
            g.Clear(Color.White);
            chart_predict.Series[0].Points.Clear();
        }

        private void button_train_Click(object sender, EventArgs e)
        {
            int trainCount = int.Parse(textbox_traincount.Text);
            string path = textbox_exportpath.Text;

            AIWrapper wrapper = new AIWrapper(textbox_exepath.Text);
            wrapper.SetNetwork(textbox_networkpath.Text);

            wrapper.SetInput(textbox_datapath.Text
                , int.Parse(textbox_dataoffset.Text)
                , int.Parse(textbox_datalength.Text)
                , dataCount);

            wrapper.SetAnswer(textbox_answerpath.Text
                , int.Parse(textbox_answeroffset.Text)
                , int.Parse(textbox_answerlength.Text)
                , answerCount);

            wrapper.Train(textbox_exportpath.Text, trainCount);
        }

        private void button_predict_Click(object sender, EventArgs e)
        {
            int paint_size = panel_paint.Width;
            int i, j, x, y;

            //for(i = 0;i < paint_size; i++)
            //{
            //    for(j = 0;j < paint_size; j++)
            //    {
            //        Console.Write(pixels[i][j] == 1 ? "X" : " ");
            //    }
            //    Console.WriteLine();
            //}

            int paintWidth = panel_paint.Width;
            int scaleSize = paintWidth / dataWidth + 1;
            byte[][] arr = new byte[dataWidth][];
            byte[] arr2 = new byte[dataWidth * dataWidth];

            for (i = 0; i < dataWidth; i++)
            {
                arr[i] = new byte[dataWidth];
            }
            for (i = 0; i < paintWidth; i++)
            {
                for (j = 0; j < paintWidth; j++)
                {
                    if (pixels[i][j] == 1)
                    {
                        x = i / scaleSize;
                        y = j / scaleSize;
                        arr[i / scaleSize][j / scaleSize] = 255;
                        arr2[x * dataWidth + y] = 255;
                    }
                }
            }

            //for(i = 0;i < arr.Length; i++)
            //{
            //    for(j = 0;j < arr.Length; j++)
            //    {
            //        Console.Write(arr[i][j] == 255 ? "X" : "0");
            //    }
            //    Console.WriteLine();
            //}

            string path = Directory.GetCurrentDirectory() + @"\temp\predict.txt";
            File.WriteAllBytes(path, arr2);

            AIWrapper wrapper = new AIWrapper(textbox_exepath.Text);
            wrapper.SetNetwork(textbox_networkpath.Text);
            wrapper.SetWeight(textbox_biasweightpath.Text);
            List<List<float>> res = wrapper.Predict(path, 0, dataWidth * dataWidth, 1);
            int tag = 0;
            foreach (List<float> lf in res)
            {
                foreach (float f in lf)
                {
                    Console.WriteLine(f);
                    chart_predict.Series[0].Points.AddXY(tag++ + "", (f * 100) + "");
                }
            }

            File.Delete(path);
        }

        private void button_test_Click(object sender, EventArgs e)
        {
            chart_test_total.Series[0].Points.Clear();
            listview_test.Items.Clear();

            int total = int.Parse(textbox_testcount.Text), correct = 0;

            AIWrapper wrapper = new AIWrapper(textbox_exepath.Text);
            wrapper.SetNetwork(textbox_networkpath.Text);
            wrapper.SetWeight(textbox_biasweightpath.Text);
            test_res = wrapper.Predict(dataPath,
                int.Parse(textbox_dataoffset.Text), dataWidth * dataWidth, total);

            int i, j = 0, result, answer;            
            foreach (List<float> lf in test_res)
            {
                result = GetMaxIdx(lf);
                answer = -1;
                for (i = 0; i < answerSplit[j].Length; i++)
                {
                    if (answerSplit[j][i].CompareTo(1) == 0)
                    {
                        answer = i;
                        break;
                    }
                }                
                if (result == answer)
                {
                    correct++;
                }
                //draw(panel_data_graph_2, j);
                Console.WriteLine("ans : " + answer + ", res : " + result 
                    + "(" + (result == answer ? "O" : "X") + ")");
                ListViewItem item = new ListViewItem(j++ + "");                
                item.SubItems.Add(answer + "");
                item.SubItems.Add(result + "");
                item.SubItems.Add((answer == result) ? "O" : "X");
                listview_test.Items.Add(item);
                //Thread.Sleep(1000);
            }
            
            chart_test_total.Series[0].Points.AddXY("Correct", correct + "");
            chart_test_total.Series[0].Points.AddXY("Wrong", (total - correct) + "");
        }

        int GetMaxIdx(List<float> arr)
        {
            int i, maxIdx = -1;
            float maxVal = float.MinValue;
            for (i = 0; i < arr.Count; i++)
            {
                if (arr[i] > maxVal)
                {
                    maxVal = arr[i];
                    maxIdx = i;
                }
            }

            return maxIdx;
        }

        private void listview_test_SelectedIndexChanged(object sender, EventArgs e)
        {
            if(listview_test.SelectedItems.Count == 1)
            {
                int seq = int.Parse(listview_test.SelectedItems[0].Text);
                Console.WriteLine("selected : " + seq);

                List<float> res = test_res[seq];
                int i, cnt = res.Count;
                StringBuilder sb = new StringBuilder();
                chart_test_item.Series[0].Points.Clear();
                for (i = 0;i < cnt; i++)
                {
                    sb.Append(res[i] + "\r\n");
                    chart_test_item.Series[0].Points.AddXY(i + "", res[i].ToString("#.####"));
                }
                textbox_test.Text = sb.ToString();
                draw(panel_data_graph_2, seq);
            }
        }
    }
}
