#include "stdafx.h"
#include <string>
#include <vector>
#include <fstream>
#include <iostream>
#include<iomanip>

using namespace std;

int _tmain(int argc, _TCHAR* argv[])
{	
	ifstream		ifile;						//创建一个fstream文件流对象
	ofstream		ofile;						//创建一个fstream文件流对象
	vector<string>  vecUrl;						//创建一个vector<string>对象
	string			strUrl;						//保存读入的每一行
	
	ifile.open("PortraitUrl.txt");				//打开文件
	if (ifile.is_open())			
	{
		while (getline(ifile, strUrl))			//会自动把\n换行符去掉 
		{
			const char* pPortraitUrl = strUrl.data();
			int nCount = strlen(pPortraitUrl);
			char* pBuf = new char[2 * nCount + 1];
			char* p = pBuf;
			for (int j = 0; j < nCount; j++)
			{
				p += sprintf(p, "%02x", pPortraitUrl[j]);
			}
			string strUrlEncryption = string(pBuf);

			vecUrl.push_back(strUrlEncryption);
		}
	}						
	ifile.close();

	ofile.open("PortraitUrlEncryption.txt");	//打开文件
	if (ofile.is_open())
	{
		for (int i = 0; i < vecUrl.size(); i++)
		{
			ofile << vecUrl[i];
			ofile << "\n";
		}
	}
	ofile.close();

	return 0;
}

