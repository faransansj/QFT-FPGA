# **QFT 데이터셋 생성 및 FPGA 적용을 위한 문서**

## **1. 개요**
본 문서는 Qiskit을 활용하여 **양자 푸리에 변환(Quantum Fourier Transform, QFT) 데이터셋을 생성**하고,  
이를 FPGA 환경에서 활용할 수 있도록 변환 및 저장하는 과정을 설명합니다.

---

## **2. 환경 설정**
### **2.1 필요한 라이브러리 설치**
본 프로젝트는 다음과 같은 라이브러리를 사용합니다.  
패키지가 설치되지 않았다면 다음 명령어를 실행하세요.

```bash
pip install qiskit qiskit-aer numpy pandas json matplotlib
```

### **2.2 Python 버전**
Qiskit은 Python 3.10 이하에서 안정적으로 동작합니다.  
현재 버전을 확인하려면 다음을 실행하세요.

```bash
python --version
```

Python 3.11 이상에서는 일부 기능이 정상적으로 작동하지 않을 수 있으므로,  
문제가 발생할 경우 **Python 3.10 이하로 다운그레이드**를 고려하세요.

---

## **3. QFT 데이터셋 생성**
### **3.1 QFT 회로 구현**
다음 코드에서는 **QFT 연산을 수행하는 양자 회로를 생성**합니다.

```python
from qiskit import QuantumCircuit, transpile
from qiskit_aer import Aer
import numpy as np
import pandas as pd
import json

# QFT를 적용할 큐비트 수 설정
num_qubits = 4

# QFT 회로 생성
def qft_circuit(n):
    qc = QuantumCircuit(n)
    for j in range(n):
        for k in range(j):
            qc.cp(np.pi / 2**(j-k), k, j)  # Controlled Phase Rotation
        qc.h(j)
    return qc

# QFT 회로 생성 및 측정 추가
qft = qft_circuit(num_qubits)
qft.measure_all()
```

---

## **4. 양자 시뮬레이션 수행**
### **4.1 시뮬레이터를 이용한 실행**
Qiskit의 `Aer` 시뮬레이터를 이용하여 QFT 회로를 실행합니다.

```python
# 시뮬레이터 설정
simulator = Aer.get_backend('aer_simulator')

# 회로 최적화 (Transpile)
compiled_qft = transpile(qft, simulator)

# 시뮬레이션 실행
result = simulator.run(compiled_qft, shots=1024).result()

# 측정 결과 확인
counts = result.get_counts()
print("QFT Measurement Result:\n", counts)
```

#### **💡 중요 사항**
- 최신 Qiskit에서는 `assemble()` 없이 `simulator.run(compiled_qft)` 방식으로 실행해야 합니다.
- `shots=1024` 옵션을 추가하여 여러 번 측정하여 확률 분포를 확인할 수 있습니다.

---

## **5. FPGA 적용을 위한 변환**
### **5.1 고정소수점 변환**
FPGA에서 활용할 수 있도록 **16비트 고정소수점(Fixed-Point) 변환**을 수행합니다.

```python
# QFT 데이터 변환 (FFT 사용)
qft_output = np.fft.fft(np.random.rand(2**num_qubits) + 1j * np.random.rand(2**num_qubits))

# 고정소수점 변환 함수
def to_fixed_point(value, bits=16):
    scale_factor = 2**(bits - 1)
    return np.round(value * scale_factor).astype(int)

qft_fixed_real = to_fixed_point(qft_output.real)
qft_fixed_imag = to_fixed_point(qft_output.imag)

print("QFT Fixed-Point Real:\n", qft_fixed_real)
print("QFT Fixed-Point Imag:\n", qft_fixed_imag)
```

---

## **6. 데이터 저장**
### **6.1 JSON 파일 저장**
```python
# JSON 데이터 구조화
data_json = {
    "qft_output_real": qft_output.real.tolist(),
    "qft_output_imag": qft_output.imag.tolist(),
    "qft_fixed_point_real": qft_fixed_real.tolist(),
    "qft_fixed_point_imag": qft_fixed_imag.tolist(),
    "measurement_counts": counts
}

# JSON 파일로 저장
with open("qft_output.json", "w") as f:
    json.dump(data_json, f, indent=4)

print("QFT 데이터가 JSON 파일로 저장되었습니다.")
```

### **6.2 CSV 파일 저장**
```python
# CSV 저장을 위한 데이터 변환
df = pd.DataFrame({
    "qft_output_real": qft_output.real,
    "qft_output_imag": qft_output.imag,
    "qft_fixed_point_real": qft_fixed_real,
    "qft_fixed_point_imag": qft_fixed_imag
})

# CSV 파일로 저장
df.to_csv("qft_output.csv", index=False)

print("QFT 데이터가 CSV 파일로 저장되었습니다.")
```

---

## **7. 발생할 수 있는 오류 및 해결 방법**
### **7.1 `ImportError: cannot import name 'Aer' from 'qiskit'`**
```bash
pip install qiskit-aer
```
```python
from qiskit_aer import Aer
```

### **7.2 `TypeError: 'QasmQobj' object is not iterable`**
```python
result = simulator.run(compiled_qft, shots=1024).result()
```

---

## **8. 결론**
- 본 문서에서는 **Qiskit을 활용하여 QFT 데이터셋을 생성**하고 **FPGA 적용을 위한 변환 및 저장 방법**을 다루었습니다.
- **JSON 및 CSV 저장**을 지원하여 향후 데이터 분석 및 FPGA 적용이 용이하도록 구성하였습니다.
- Qiskit 최신 버전에서 발생하는 **에러 해결 방법**을 포함하여 안정적인 실행이 가능하도록 문서화하였습니다.

본 문서는 **FPGA 기반의 양자-고전 하이브리드 시스템 연구**에서 유용한 자료가 될 것입니다. 🚀