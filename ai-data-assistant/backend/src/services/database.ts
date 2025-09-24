import { supabase } from '../config/supabase';
import { TableInfo, ColumnInfo, QueryResult, FilterOption, SortOption } from '@ai-data-assistant/shared';
import logger from '../config/logger';

export class DatabaseService {
  async getTables(): Promise<TableInfo[]> {
    try {
      // For now, return a basic list of tables
      // In a real implementation, this would query the database schema
      const tables: TableInfo[] = [
        {
          name: 'users',
          schema: 'public',
          columns: [
            { name: 'id', type: 'uuid', nullable: false, isPrimaryKey: true },
            { name: 'email', type: 'text', nullable: false, isPrimaryKey: false },
            { name: 'name', type: 'text', nullable: true, isPrimaryKey: false },
            { name: 'created_at', type: 'timestamp', nullable: false, isPrimaryKey: false }
          ],
          primaryKey: ['id']
        },
        {
          name: 'products',
          schema: 'public',
          columns: [
            { name: 'id', type: 'uuid', nullable: false, isPrimaryKey: true },
            { name: 'name', type: 'text', nullable: false, isPrimaryKey: false },
            { name: 'price', type: 'numeric', nullable: false, isPrimaryKey: false },
            { name: 'description', type: 'text', nullable: true, isPrimaryKey: false },
            { name: 'created_at', type: 'timestamp', nullable: false, isPrimaryKey: false }
          ],
          primaryKey: ['id']
        }
      ];

      return tables;
    } catch (error) {
      logger.error('Error fetching tables:', error);
      throw new Error('Failed to fetch tables');
    }
  }

  async getTableColumns(tableName: string): Promise<ColumnInfo[]> {
    try {
      // For Supabase, we can't directly query information_schema
      // Instead, we'll get sample data and infer column types
      const { data: sampleData, error } = await supabase
        .from(tableName)
        .select('*')
        .limit(1);

      if (error) throw error;

      if (!sampleData || sampleData.length === 0) {
        // If no data, return empty columns
        return [];
      }

      // Infer columns from the first row of data
      const firstRow = sampleData[0];
      const columns: ColumnInfo[] = [];

      for (const [columnName, value] of Object.entries(firstRow)) {
        let columnType = 'unknown';
        
        if (typeof value === 'string') {
          columnType = 'text';
        } else if (typeof value === 'number') {
          columnType = Number.isInteger(value) ? 'integer' : 'numeric';
        } else if (typeof value === 'boolean') {
          columnType = 'boolean';
        } else if (value instanceof Date) {
          columnType = 'timestamp';
        } else if (value === null) {
          columnType = 'unknown';
        }

        columns.push({
          name: columnName,
          type: columnType,
          nullable: value === null,
          isPrimaryKey: columnName === 'id' // Simple heuristic for primary key
        });
      }

      return columns;
    } catch (error) {
      logger.error(`Error fetching columns for table ${tableName}:`, error);
      throw new Error(`Failed to fetch columns for table ${tableName}`);
    }
  }

  async executeQuery(
    tableName: string,
    filters: FilterOption[] = [],
    sorts: SortOption[] = [],
    page = 1,
    pageSize = 50,
    searchQuery?: string
  ): Promise<QueryResult> {
    try {
      const startTime = Date.now();
      let query = supabase.from(tableName).select('*', { count: 'exact' });

      // Apply filters
      filters.forEach(filter => {
        switch (filter.operator) {
          case 'eq':
            query = query.eq(filter.column, filter.value);
            break;
          case 'neq':
            query = query.neq(filter.column, filter.value);
            break;
          case 'gt':
            query = query.gt(filter.column, filter.value);
            break;
          case 'gte':
            query = query.gte(filter.column, filter.value);
            break;
          case 'lt':
            query = query.lt(filter.column, filter.value);
            break;
          case 'lte':
            query = query.lte(filter.column, filter.value);
            break;
          case 'like':
            query = query.ilike(filter.column, `%${filter.value}%`);
            break;
          case 'in':
            query = query.in(filter.column, filter.value);
            break;
        }
      });

      // Apply search across all text columns
      if (searchQuery) {
        const columns = await this.getTableColumns(tableName);
        const textColumns = columns.filter(col =>
          col.type.includes('text') || col.type.includes('varchar')
        );

        if (textColumns.length > 0) {
          const orConditions = textColumns.map(col =>
            `${col.name}.ilike.%${searchQuery}%`
          ).join(',');
          query = query.or(orConditions);
        }
      }

      // Apply sorting
      sorts.forEach(sort => {
        query = query.order(sort.column, { ascending: sort.direction === 'asc' });
      });

      // Apply pagination
      const start = (page - 1) * pageSize;
      query = query.range(start, start + pageSize - 1);

      const { data, error, count } = await query;

      if (error) throw error;

      const executionTime = Date.now() - startTime;

      return {
        data: data || [],
        count: count || 0,
        query: 'SELECT query not available', // We'd need to build this
        executionTime
      };
    } catch (error) {
      logger.error('Error executing query:', error);
      throw new Error('Failed to execute query');
    }
  }

  async executeRawSQL(sqlQuery: string): Promise<QueryResult> {
    try {
      const startTime = Date.now();

      // Note: Supabase doesn't directly support raw SQL execution in the client
      // This would need to be implemented using RPC functions or edge functions
      // For now, we'll return a placeholder

      const executionTime = Date.now() - startTime;

      logger.warn('Raw SQL execution not implemented yet:', sqlQuery);

      return {
        data: [],
        count: 0,
        query: sqlQuery,
        executionTime
      };
    } catch (error) {
      logger.error('Error executing raw SQL:', error);
      throw new Error('Failed to execute raw SQL');
    }
  }

  async getTableSample(tableName: string, sampleSize = 5): Promise<Record<string, any>[]> {
    try {
      const { data, error } = await supabase
        .from(tableName)
        .select('*')
        .limit(sampleSize);

      if (error) throw error;
      return data || [];
    } catch (error) {
      logger.error(`Error fetching sample data for table ${tableName}:`, error);
      throw new Error(`Failed to fetch sample data for table ${tableName}`);
    }
  }
}