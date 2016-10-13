#define FILTERSCRIPT

#include <a_samp>
#include <streamer>

#define VERSION 0.1
#define TEMPSMAXJOB 10


#define SCM SendClientMessage

//~~~~~~~~~~~~~~~~~ Enums ~~~~~~~~~~~~~~~~~

enum tInfos
{
	tID,
	Float:tposX,
	Float:tposY,
	Float:tposZ,
	Float:tposA,
	tcolor1,
	tcolor2,
	tresdelay,
	tsiren
};

enum pInfos
{
	pJob,
	bool: jobStarted,
	bool: isTiming
};

//~~~~~~~~~~~~~~~~ Arrays ~~~~~~~~~~~~~~~~~



new
	TrashCar[][tInfos] = {
	
	},
	
	PosSpawn[1][3] = {
	
	},
	
	PosVideOrdure[1][3] = {
	
	},
	
	PosTrash[][7] = {
	
	{ 1333, float: -2776.000000, float: -399.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2774.000000, float: -341.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -2800.000000, float: 115.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -2477.000000, float: -184.000000, float: 25.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -2456.000000, float: -112.000000, float: 26.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -2541.000000, float: 6.000000, float: 16.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -2533.000000, float: 58.000000, float: 8.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -2521.000000, float: 249.000000, float: 11.000000, float: 0.00000, float: 0.00000, float: 10.000000 },
	{ 1333, float: -2690.000000, float: 226.000000, float: 4.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2757.000000, float: 247.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2494.000000, float: 297.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: -104.000000 },
	{ 1333, float: -2594.000000, float: 663.000000, float: 14.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2673.000000, float: 741.000000, float: 28.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -2684.000000, float: 835.000000, float: 50.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -2684.000000, float: 903.000000, float: 79.000000, float: 0.00000, float: 0.00000, float: 11.000000 },
	{ 1333, float: -2719.000000, float: 1013.000000, float: 55.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2859.000000, float: 943.000000, float: 44.000000, float: 0.00000, float: 0.00000, float: -65.000000 },
	{ 1333, float: -2636.000000, float: 872.000000, float: 64.000000, float: 0.00000, float: 0.00000, float: 80.000000 },
	{ 1333, float: -2593.000000, float: 1205.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: -135.000000 },
	{ 1333, float: -2508.000000, float: 1229.000000, float: 37.000000, float: 0.00000, float: 0.00000, float: -20.000000 },
	{ 1333, float: -2519.000000, float: 2370.000000, float: 5.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2239.000000, float: 2356.000000, float: 5.000000, float: 0.00000, float: 0.00000, float: -46.000000 },
	{ 1333, float: -1517.000000, float: 2568.000000, float: 56.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1457.000000, float: 2625.000000, float: 56.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: 74.000000, float: 1155.000000, float: 18.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -673.000000, float: 959.000000, float: 12.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: 158.000000, float: -178.000000, float: 1.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1049.000000, float: -691.000000, float: 32.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -2417.000000, float: 444.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: 429.000000, float: 2552.000000, float: 16.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: 180.000000, float: 1428.000000, float: 10.000000, float: 0.00000, float: 0.00000, float: 98.000000 },
	{ 1333, float: -85.000000, float: 1236.000000, float: 19.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -2459.000000, float: 774.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -2412.000000, float: 999.000000, float: 50.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -2448.000000, float: 1141.000000, float: 55.000000, float: 0.00000, float: 0.00000, float: -5.000000 },
	{ 1333, float: -2454.000000, float: 1389.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2359.000000, float: -171.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: -55.000000 },
	{ 1333, float: -1997.000000, float: -1031.000000, float: 32.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -1892.000000, float: -845.000000, float: 32.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2210.000000, float: 443.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -2218.000000, float: 645.000000, float: 49.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2216.000000, float: 1057.000000, float: 80.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2173.000000, float: 1232.000000, float: 34.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1811.000000, float: -441.000000, float: 15.000000, float: 0.00000, float: 0.00000, float: -100.000000 },
	{ 1333, float: -1486.000000, float: -230.000000, float: 14.000000, float: 0.00000, float: 0.00000, float: -95.000000 },
	{ 1333, float: 793.000000, float: 1700.000000, float: 5.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: 672.000000, float: 1708.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1389.000000, float: -162.000000, float: 6.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1957.000000, float: 1098.000000, float: 55.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -1940.000000, float: 1193.000000, float: 45.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -1917.000000, float: -448.000000, float: 25.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -1956.000000, float: 801.000000, float: 55.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1982.000000, float: 620.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1911.000000, float: 309.000000, float: 41.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1960.000000, float: 109.000000, float: 27.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -2027.000000, float: 1026.000000, float: 55.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1938.000000, float: -568.000000, float: 24.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2059.000000, float: 98.000000, float: 28.000000, float: 0.00000, float: 0.00000, float: -5.000000 },
	{ 1333, float: -2083.000000, float: 876.000000, float: 69.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2042.000000, float: 984.000000, float: 54.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -2071.000000, float: 1000.000000, float: 63.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -2037.000000, float: 1119.000000, float: 53.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -2121.000000, float: 577.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1641.000000, float: 1310.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: -45.000000 },
	{ 1333, float: -1734.000000, float: 1436.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -1818.000000, float: 1314.000000, float: 19.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1761.000000, float: 1115.000000, float: 45.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1713.000000, float: 1005.000000, float: 18.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1772.000000, float: 764.000000, float: 25.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1833.000000, float: 669.000000, float: 30.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -1833.000000, float: -45.000000, float: 15.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -1835.000000, float: 368.000000, float: 17.000000, float: 0.00000, float: 0.00000, float: -30.000000 },
	{ 1333, float: -1756.000000, float: 907.000000, float: 25.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1740.000000, float: 1234.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1778.000000, float: 1308.000000, float: 59.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1642.000000, float: 67.000000, float: 3.000000, float: 0.00000, float: 0.00000, float: 224.000000 },
	{ 1333, float: -1697.000000, float: -38.000000, float: 3.000000, float: 0.00000, float: 0.00000, float: 135.000000 },
	{ 1333, float: -1577.000000, float: 359.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1474.000000, float: 341.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1539.000000, float: 569.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 215.000000 },
	{ 1333, float: -1729.000000, float: 641.000000, float: 25.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -1628.000000, float: 789.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1485.000000, float: 662.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1733.000000, float: 1028.000000, float: 45.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -1518.000000, float: 1180.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -1639.000000, float: 1175.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1450.000000, float: 1000.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -2674.000000, float: -338.000000, float: 6.000000, float: 0.00000, float: 0.00000, float: 45.000000 },
	{ 1333, float: -2786.000000, float: -201.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2750.000000, float: 49.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2715.000000, float: 120.000000, float: 4.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -2446.000000, float: 9.000000, float: 25.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -2587.000000, float: 94.000000, float: 4.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2457.000000, float: 108.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2560.000000, float: 306.000000, float: 16.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -2586.000000, float: 487.000000, float: 14.000000, float: 0.00000, float: 0.00000, float: -46.000000 },
	{ 1333, float: -2863.000000, float: 418.000000, float: 4.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -2771.000000, float: 796.000000, float: 52.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -2572.000000, float: 983.000000, float: 78.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -2664.000000, float: 1453.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -2446.000000, float: 2252.000000, float: 5.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2486.000000, float: 2540.000000, float: 18.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1953.000000, float: 2379.000000, float: 49.000000, float: 0.00000, float: 0.00000, float: -68.000000 },
	{ 1333, float: -2450.000000, float: 755.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2501.000000, float: 896.000000, float: 65.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -2435.000000, float: 1291.000000, float: 22.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -2394.000000, float: -617.000000, float: 132.000000, float: 0.00000, float: 0.00000, float: 215.000000 },
	{ 1333, float: -1903.000000, float: -1700.000000, float: 21.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: 264.000000, float: 13.000000, float: 2.000000, float: 0.00000, float: 0.00000, float: 190.000000 },
	{ 1333, float: -330.000000, float: 829.000000, float: 14.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -779.000000, float: 2765.000000, float: 46.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -293.000000, float: 2683.000000, float: 62.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -87.000000, float: 1371.000000, float: 10.000000, float: 0.00000, float: 0.00000, float: 100.000000 },
	{ 1333, float: 212.000000, float: -237.000000, float: 1.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: 60.000000, float: -332.000000, float: 1.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -105.000000, float: -300.000000, float: 1.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2176.000000, float: 957.000000, float: 80.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -2169.000000, float: 1219.000000, float: 47.000000, float: 0.00000, float: 0.00000, float: 50.000000 },
	{ 1333, float: -2220.000000, float: 821.000000, float: 49.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2199.000000, float: 617.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2199.000000, float: 79.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2199.000000, float: 113.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2206.000000, float: 330.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2095.000000, float: -389.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1944.000000, float: -728.000000, float: 32.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -2319.000000, float: 1033.000000, float: 50.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2290.000000, float: 1103.000000, float: 80.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2120.000000, float: 1.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2076.000000, float: -101.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -2059.000000, float: 165.000000, float: 29.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2067.000000, float: 329.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -2089.000000, float: 746.000000, float: 69.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1910.000000, float: 1375.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1997.000000, float: -211.000000, float: 36.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -1923.000000, float: 167.000000, float: 26.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -1978.000000, float: 309.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1903.000000, float: 507.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -1944.000000, float: 678.000000, float: 46.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1983.000000, float: 957.000000, float: 45.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1887.000000, float: -213.000000, float: 23.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1854.000000, float: -167.000000, float: 9.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1811.000000, float: -153.000000, float: 9.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1382.000000, float: -364.000000, float: 14.000000, float: 0.00000, float: 0.00000, float: -85.000000 },
	{ 1333, float: -1446.000000, float: -203.000000, float: 6.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -1423.000000, float: 46.000000, float: 6.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1358.000000, float: -640.000000, float: 14.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -1697.000000, float: -598.000000, float: 14.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1860.000000, float: 111.000000, float: 15.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1835.000000, float: 564.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 55.000000 },
	{ 1333, float: -1873.000000, float: 743.000000, float: 45.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1806.000000, float: 867.000000, float: 25.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -1852.000000, float: 988.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1838.000000, float: 1046.000000, float: 46.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1779.000000, float: 1208.000000, float: 25.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1834.000000, float: 1541.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1661.000000, float: 1367.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 223.000000 },
	{ 1333, float: -1819.000000, float: 1143.000000, float: 45.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1708.000000, float: 1225.000000, float: 30.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1619.000000, float: 1015.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -1675.000000, float: 1008.000000, float: 8.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1745.000000, float: 1084.000000, float: 45.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1629.000000, float: 720.000000, float: 14.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1618.000000, float: 679.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: -1554.000000, float: 471.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 240.000000 },
	{ 1333, float: -1677.000000, float: 436.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 135.000000 },
	{ 1333, float: -1737.000000, float: 260.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 240.000000 },
	{ 1333, float: -1742.000000, float: 57.000000, float: 3.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -2591.000000, float: -180.000000, float: 4.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -2686.000000, float: 425.000000, float: 4.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -2705.000000, float: 1321.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -2409.000000, float: -2184.000000, float: 33.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -622.000000, float: -483.000000, float: 25.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -170.000000, float: 1169.000000, float: 20.000000, float: 0.00000, float: 0.00000, float: 0.000000 },
	{ 1333, float: 700.000000, float: 1952.000000, float: 5.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -551.000000, float: 2607.000000, float: 54.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -2284.000000, float: -24.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -2280.000000, float: 217.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -2275.000000, float: 458.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -2286.000000, float: 583.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -2306.000000, float: 731.000000, float: 49.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -2008.000000, float: -500.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -2225.000000, float: -102.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -2126.000000, float: 120.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -2049.000000, float: -40.000000, float: 35.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -2044.000000, float: 1194.000000, float: 45.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -2050.000000, float: 1232.000000, float: 31.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1990.000000, float: 1345.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -1571.000000, float: 880.000000, float: 7.000000, float: 0.00000, float: 0.00000, float: -90.000000 },
	{ 1333, float: -1665.000000, float: 942.000000, float: 25.000000, float: 0.00000, float: 0.00000, float: 180.000000 },
	{ 1333, float: -124.000000, float: 1076.000000, float: 20.000000, float: 0.00000, float: 0.00000, float: 90.000000 },
	{ 1333, float: -218.000000, float: 1166.000000, float: 20.000000, float: 0.00000, float: 0.00000, float: -92.000000 }
	
	};
	
	
	
//~~~~~~~~~~~~~~~~ News ~~~~~~~~~~~~~~~~~~

new
	trash[] = {
	
	
	},
	Joueur[MAX_PLAYERS][pInfos],
	truck,
	trashplayer[MAX_PLAYERS],
	cpt[MAX_PLAYERS];
	


public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	printf("Job éboueur GTRP V%f", VERSION);
	print("--------------------------------------\n");
	
	for(new i = 0; i < sizeof(PosTrash); i++)
	{
	    trash[i] = CreateDynamicObject(PosTrash[i][0], PosTrash[i][1], PosTrash[i][2], PosTrash[i][3], PosTrash[i][4], PosTrash[i][5], PosTrash[i][6]);
	}
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
	    Joueur[i][pJob] = -1;
		Joueur[i][jobStarted] = false;
		Joueur[i][isTiming] = false;
		trashplayer[i] = -1;
		cpt[i] = -1;
	}
	SetTimer("Timer1s", 1000, true);
	truck = CreateVehicle(408, -1969.4143, 101.7806, 28.2321, 89.7910, 0, 0, -1, 0);
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

public OnPlayerConnect(playerid)
{
	Joueur[playerid][pJob] = -1;
	Joueur[playerid][jobStarted] = false;
	Joueur[playerid][isTiming] = false;
	trashplayer[playerid] = -1;
	cpt[playerid] = -1;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(strcmp("je suis gay", text, true) == 0)
	{
	    SetPlayerHealth(playerid, 0);
	    SCM(playerid, -1, "L'homosexualité est interdit dans l'état de Californie, vous avez été tué");
	}
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/dustman", cmdtext, true) == 0)
	{
		if(Joueur[playerid][pJob] == -1)
		{
	 		Joueur[playerid][pJob] = 16;
	 		SCM(playerid, -1, "Vous êtes devenu éboueur !");
		}
		else
		{
			Joueur[playerid][pJob] = -1;
			SCM(playerid, -1, "Vous n'êtes plus éboueur !");
		}
		return 1;
	}
	
	if (strcmp("/start", cmdtext, true) == 0)
	{
	    if(Joueur[playerid][pJob] != 16) return SCM(playerid, -1, "Vous n'êtes pas éboueur !");
	    if(!IsPlayerInVehicle(playerid, truck)) return SCM(playerid, -1, "Vous n'êtes pas dans le camion benne !");
	    if(Joueur[playerid][jobStarted]) return SCM(playerid, -1, "Vous êtes déjà en train de travailler !");
		if(trashplayer[playerid] != -1) return SCM(playerid, -1, "Vous devez déjà allé à une poubelle !");

		new
			trashid = GetNearestTrashToPlayer(playerid);
	    
	    trashplayer[playerid] = CreateDynamicCP(PosTrash[trashid][1], PosTrash[trashid][2], PosTrash[trashid][3], 5.0);
	    SCM(playerid, -1, "Rendez vous prêt du checkpoint, puis descendez à pied !");
	    SCM(playerid, -1, "Une fois arrivé, vous avez 30 secondes pour mettre le contenu de la poubelle dans le camion");
	    //CreateDynamicCP(Float:x, Float:y, Float:z, Float:size)
	    
	    return 1;
	}
	return 0;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{

	if(checkpointid == trashplayer[playerid])
	{
	    if(IsPlayerInAnyVehicle(playerid)) return SCM(playerid, -1, "Vous devez être à pied pour ramasser la poubelle !");

	}
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT)
	{
	    if(Joueur[playerid][jobStarted] && !Joueur[playerid][isTiming])
	    {
	        cpt[playerid] = TEMPSMAXJOB;
	        Joueur[playerid][isTiming] = true;
	        SCM(playerid, -1, "Vous devez remonter dans votre camion benne pour continuer !");
	    }
	}
	
	if(oldstate == PLAYER_STATE_ONFOOT && newstate == PLAYER_STATE_DRIVER)
	{
	    new
	        vehid = GetPlayerVehicleID(playerid),
			modelid = GetVehicleModel(vehid),
			seatid = GetPlayerVehicleSeat(playerid);
			
		if(modelid == 408)
		{
		    if(seatid == 0)
		    {
		        cpt[playerid] = -1;
		        Joueur[playerid][isTiming] = false;
		        SCM(playerid, -1, "Vous êtes revenu dans le camion !");
		    }
		}


	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

forward Timer1s();


public Timer1s()
{
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
	    if(cpt[i] > 0) cpt[i]--;
	    else if (cpt[i] == 0)
	    {
	        Joueur[i][jobStarted] = false;
	        trashplayer[i] = -1;
	        cpt[i] = -1;
	        SCM(i, -1, "Vous avez été retiré de la mission !");
	        Joueur[i][isTiming] = false;
	    }
	}
}

GetNearestTrashToPlayer(playerid)
{
    new
		Float:result = 999999.0,
		trashid,
		Float:pos[3];

	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	for(new i = 0; i < sizeof(PosTrash);i++)
	{
		new Float:var = floatsqroot(floatpower(PosTrash[i][1]-pos[1], 2) + floatpower(PosTrash[i][2]-pos[2], 2));
		if(result > var)
		{
		    result = var;
		    trashid = i;
		}
	}

	return trashid;
}

stock GetXYBackOfPlayer(const playerid, &Float:x, &Float:y, const Float:distance)
{
	new
		Float:a;
		
	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);
	x -= (distance * floatsin(-a, degrees));
	y -= (distance * floatcos(-a, degrees));
}

