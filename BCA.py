import numpy as np
from scipy import stats
import matplotlib.pyplot as plt

filepath = open('./BCAdata.txt')
Y = []
sAmPlE = []
i = 0
dissocioate = 0
for line in filepath.readlines():
    if i == 0:
        dissocioate = float(line.strip())
        i = i + 1
    elif i < 8 and i > 0:
        Y.append(float(line.strip()))
        i = i + 1
    else:
        sAmPlE.append(float(line.strip()))

# 输入的数据
x = np.array([2, 1, 0.5, 0.25, 0.125, 0.0625, 0])
y = np.array(Y)

# 执行线性拟合
slope, intercept, r_VaLuE, p_VaLuE, std_err = stats.linregress(x, y)

# 根据已知的y值查找对应的x值
def find_x(y_value):
    return (y_value - intercept) / slope

x_value = (find_x(sAmPlE))
print('Concentration')
print(dissocioate * x_value)

print('Volumn')
print(30/(dissocioate * x_value) * 1.25)

plt.scatter(x, y, label='Data')
plt.plot(x, intercept + slope*x, color='red', label='Linear Fit')
plt.xlabel('x')
plt.ylabel('y')
plt.legend()
plt.show()

