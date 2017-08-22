﻿// Copyright (c) Microsoft. All rights reserved.

namespace Microsoft.Azure.Devices.Edge.Hub.Storage.RocksDb
{
    using System;
    using System.Threading.Tasks;
    using DotNetty.Common.Utilities;
    using Microsoft.Azure.Devices.Edge.Hub.Core.Storage;
    using Microsoft.Azure.Devices.Edge.Util;
    using RocksDbSharp;

    class ColumnFamilyDbStore : IDbStore
    {
        readonly RocksDbWrapper db;
        readonly ColumnFamilyHandle handle;

        public ColumnFamilyDbStore(RocksDbWrapper db, ColumnFamilyHandle handle)
        {
            this.db = Preconditions.CheckNotNull(db, nameof(db));
            this.handle = Preconditions.CheckNotNull(handle, nameof(handle));
        }

        public Task<Option<byte[]>> Get(byte[] key)
        {
            Preconditions.CheckNotNull(key, nameof(key));
            byte[] value = this.db.Get(key, this.handle);
            Option<byte[]> returnValue = value != null ? Option.Some(value) : Option.None<byte[]>();
            return Task.FromResult(returnValue);
        }

        public Task Put(byte[] key, byte[] value)
        {
            Preconditions.CheckNotNull(key, nameof(key));
            Preconditions.CheckNotNull(value, nameof(value));

            this.db.Put(key, value, this.handle);
            return Task.CompletedTask;
        }

        public Task Remove(byte[] key)
        {
            Preconditions.CheckNotNull(key, nameof(key));
            this.db.Remove(key, this.handle);
            return Task.CompletedTask;
        }        

        public Task<Option<(byte[] key, byte[] value)>> GetLastEntry()
        {
            using (Iterator iterator = this.db.NewIterator(this.handle))
            {
                iterator.SeekToLast();
                if (iterator.Valid())
                {
                    byte[] key = iterator.Key();
                    byte[] value = iterator.Value();
                    return Task.FromResult(Option.Some((key, value)));
                }
                else
                {
                    return Task.FromResult(Option.None<(byte[], byte[])>());
                }
            }
        }

        public Task<Option<(byte[] key, byte[] value)>> GetFirstEntry()
        {
            using (Iterator iterator = this.db.NewIterator(this.handle))
            {
                iterator.SeekToFirst();
                if (iterator.Valid())
                {
                    byte[] key = iterator.Key();
                    byte[] value = iterator.Value();
                    return Task.FromResult(Option.Some((key, value)));
                }
                else
                {
                    return Task.FromResult(Option.None<(byte[], byte[])>());
                }
            }
        }

        public Task<bool> Contains(byte[] key)
        {
            Preconditions.CheckNotNull(key, nameof(key));
            byte[] value = this.db.Get(key, this.handle);
            return Task.FromResult(value != null);
        }

        public Task IterateBatch(byte[] startKey, int batchSize, Func<byte[], byte[], Task> callback)
        {
            Preconditions.CheckNotNull(startKey, nameof(startKey));
            Preconditions.CheckRange(batchSize, 1, nameof(batchSize));
            Preconditions.CheckNotNull(callback, nameof(callback));

            return this.IterateBatch(iterator => iterator.Seek(startKey), batchSize, callback);
        }

        public Task IterateBatch(int batchSize, Func<byte[], byte[], Task> callback)
        {
            Preconditions.CheckRange(batchSize, 1, nameof(batchSize));
            Preconditions.CheckNotNull(callback, nameof(callback));

            return this.IterateBatch(iterator => iterator.SeekToFirst(), batchSize, callback);
        }

        async Task IterateBatch(Action<Iterator> seeker, int batchSize, Func<byte[], byte[], Task> callback)
        {
            // Use tailing iterator to prevent creating a snapshot. 
            var readOptions = new ReadOptions();
            readOptions.SetTailing(true);

            Iterator iterator = this.db.NewIterator(this.handle, readOptions);
            int counter = 0;
            for (seeker(iterator); iterator.Valid() && counter < batchSize; iterator.Next(), counter++)
            {
                byte[] key = iterator.Key();
                byte[] value = iterator.Value();
                await callback(key, value);
            }
        }

        protected virtual void Dispose(bool disposing)
        {
            if (disposing)
            {
                this.db?.Dispose();
            }
        }

        public void Dispose()
        {
            this.Dispose(true);
            GC.SuppressFinalize(this);
        }
    }
}