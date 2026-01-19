/**
 * Módulo Transform - API Pública Estable
 * 
 * Este archivo expone el contrato público del módulo Transform.
 * 
 * IMPORTANTE: Esta API es estable y no debe cambiar sin revisión.
 * 
 * Uso recomendado:
 * - Para core headless: importar desde '@/modules/transform/core'
 * - Para adapter React: importar desde '@/modules/transform/adapters/react'
 * - Para acceso centralizado: importar desde '@/modules/transform' (este archivo)
 */

// Re-export del core (headless)
export * from './core';

// Re-export del adapter React
export * from './adapters/react';
