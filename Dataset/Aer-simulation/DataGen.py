from qiskit import QuantumCircuit, transpile, assemble
from qiskit_aer import Aer  

import numpy as np
import pandas as pd
import json
import matplotlib.pyplot as plt

# QFT를 적용할 큐비트 수 설정
num_qubits = 4

# 랜덤 입력 데이터 생성 (복소수 신호)
input_data = np.random.rand(2**num_qubits) + 1j * np.random.rand(2**num_qubits)
print("Input Data:\n", input_data)

# QFT 회로 생성 함수
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

# 시뮬레이션 수행
simulator = Aer.get_backend('aer_simulator')
compiled_qft = transpile(qft, simulator)
result = simulator.run(compiled_qft, shots=1024).result()

# 측정 결과 확인
counts = result.get_counts()
print("QFT Measurement Result:\n", counts)

# QFT 데이터 변환 (FPGA용 고정소수점 변환)
qft_output = np.fft.fft(input_data)  # FFT 적용 (QFT와 유사)
qft_fixed_point = np.round(qft_output * (2**15)).astype(int)  # 16비트 고정소수점 변환

print("Fixed-Point QFT Output:\n", qft_fixed_point)

# JSON으로 저장
data_json = {
    "input_data_real": input_data.real.tolist(),
    "input_data_imag": input_data.imag.tolist(),
    "qft_output_real": qft_output.real.tolist(),
    "qft_output_imag": qft_output.imag.tolist(),
    "qft_fixed_point_real": qft_fixed_point.real.tolist(),
    "qft_fixed_point_imag": qft_fixed_point.imag.tolist(),
    "measurement_counts": counts
}

with open("qft_output.json", "w") as f:
    json.dump(data_json, f, indent=4)

print("QFT 데이터가 JSON 파일로 저장되었습니다.")

# CSV로 저장
df = pd.DataFrame({
    "input_data_real": input_data.real,
    "input_data_imag": input_data.imag,
    "qft_output_real": qft_output.real,
    "qft_output_imag": qft_output.imag,
    "qft_fixed_point_real": qft_fixed_point.real,
    "qft_fixed_point_imag": qft_fixed_point.imag
})

df.to_csv("qft_output.csv", index=False)

print("QFT 데이터가 CSV 파일로 저장되었습니다.")
