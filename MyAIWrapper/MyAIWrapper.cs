using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;

namespace MyAIWrapper
{
    public class LayerBuilder
    {
        public List<ILayer> layers;

        public LayerBuilder()
        {
            layers = new List<ILayer>();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns>network format</returns>
        public string GetString()
        {
            StringBuilder sb = new StringBuilder();

            foreach (ILayer l in layers)
            {
                sb.AppendLine(l.Export());
            }

            return sb.ToString();
        }

        /// <summary>
        /// save to path
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        public void Save(string path)
        {
            File.WriteAllText(path, GetString());
        }
    }

    public interface ILayer
    {
        string Export();
    }

    public class Affine : ILayer
    {
        int DataSize;
        int WeightSize;
        bool Result;
        bool Dropout;

        public Affine(int dataSize, int weightSize, bool result, bool dropout)
        {
            DataSize = dataSize;
            WeightSize = weightSize;
            Result = result;
            Dropout = dropout;
        }
        public string Export()
        {
            return "1 " + DataSize + " " + WeightSize + " "
                + (Result ? 1 : 0) + " " + (Dropout ? 1 : 0);
        }
    }

    public class Convolution : ILayer
    {
        int DataWidth;
        int FilterWidth;
        int ChannelCount;

        public Convolution(int dataWidth, int filterWidth, int channelCount)
        {
            DataWidth = dataWidth;
            FilterWidth = filterWidth;
            ChannelCount = channelCount;
        }

        public string Export()
        {
            return "2 " + DataWidth + " " + FilterWidth + " " + ChannelCount;
        }
    }

    public class Pooling : ILayer
    {
        int DataWidth;
        int FilterWidth;

        public Pooling(int dataWidth, int filterWidth)
        {
            DataWidth = dataWidth;
            FilterWidth = filterWidth;
        }

        public string Export()
        {
            return "3 " + DataWidth + " " + FilterWidth;
        }
    }

    public class AIWrapper
    {
        public string exePath;
        public string networkPath;
        public string inputPath;
        public string answerPath;
        public string weightPath;

        public int iOffset;
        public int iSize;
        public int iCount;

        public int aOffset;
        public int aSize;
        public int aCount;

        private Process exe;

        public AIWrapper(string path)
        {
            this.exePath = path;
        }

        public void SetNetwork(string path)
        {
            networkPath = path;
        }

        public void SetNetwork(LayerBuilder layerBuilder)
        {
            networkPath = Directory.GetCurrentDirectory() + @"\network.txt";
            layerBuilder.Save(networkPath);
        }

        /// <summary>
        /// SetInput
        /// </summary>
        /// <param name="path">binary file path</param>
        /// <param name="offset">offset</param>
        /// <param name="size">size of 1 set</param>
        /// <param name="count">number of sets</param>
        public void SetInput(string path, int offset, int size, int count)
        {
            inputPath = path;
            iOffset = offset;
            iSize = size;
            iCount = count;
        }

        /// <summary>
        /// SetAnswer
        /// </summary>
        /// <param name="path">binary file path</param>
        /// <param name="offset">offset</param>
        /// <param name="size">size of 1 set</param>
        /// <param name="count">number of sets</para
        public void SetAnswer(string path, int offset, int size, int count)
        {
            answerPath = path;
            aOffset = offset;
            aSize = size;
            aCount = count;
        }

        public void SetWeight(string path)
        {
            weightPath = path;
        }

        /// <summary>
        /// Train
        /// </summary>
        /// <param name="count">train count</param>
        /// <param name="path">export weight path</param>
        public void Train(string path, int count)
        {
            if (Start())
            {
                Waiting(false);
                Command("-ss " + networkPath);
                Command("-si " + inputPath + " " + iOffset + " " + iSize + " " + iCount);
                Command("-sa " + answerPath + " " + aOffset + " " + aSize + " " + aCount);
                Command("-t " + count, true);
                Command("-ew " + path);
                Close();
            }
        }

        /// <summary>
        /// Predict
        /// </summary>
        /// <param name="path">test data file path</param>
        public List<List<float>> Predict(string path, int offset, int size, int count, bool print = false)
        {
            if (Start())
            {
                Waiting(false);
                List<List<float>> res = new List<List<float>>();
                Command("-ss " + networkPath);
                Command("-iw " + weightPath);
                List<string> answers = Command("-p " + path + " " + offset + " " + size + " " + count, print);
                foreach(string s in answers)
                {
                    if(s.Length > 0 && s[0] == '/')
                    {                        
                        string[] split = s.Split(new string[] { "/" }, StringSplitOptions.RemoveEmptyEntries);
                        List<float> fl = new List<float>();
                        foreach(string sp in split)
                        {
                            fl.Add(float.Parse(sp));
                        }
                        res.Add(fl);
                    }
                }
                Close();
                return res;
            }
            else
            {
                return null;
            }
        }

        public bool Start()
        {
            exe = new Process();
            exe.StartInfo.FileName = exePath;
            exe.StartInfo.UseShellExecute = false;
            exe.StartInfo.RedirectStandardInput = true;
            exe.StartInfo.RedirectStandardOutput = true;
            return exe.Start();
        }

        public void Close()
        {
            exe.Close();
        }

        public List<string> Command(string cmd, bool print = false)
        {
            StreamWriter sw = exe.StandardInput;
            sw.WriteLine(cmd);
            return Waiting(print);
        }

        public List<string> Waiting(bool print)
        {
            StreamReader sr = exe.StandardOutput;
            List<string> res = new List<string>();
            string s = "";
            while (s != "input command ...")
            {
                s = sr.ReadLine();
                res.Add(s);
                if (print && s != "input command ...")
                {
                    Console.WriteLine(s);
                }
            }

            return res;
        }
    }
}
