"""Seguimiento SEPARADO: lo que pasa cuando sacamos el componente del monolito.

Piezas:
  contrato.py   el mensaje que viaja entre el monolito y el seguimiento (el «contrato»)
  publicador.py lo usa el monolito para enviar un evento a la cola
  trabajador.py proceso aparte que lee la cola y guarda en la base
  consulta.py   lee el historial desde la base
"""
